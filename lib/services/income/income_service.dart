import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/income_sources.dart';
import '../../core/constants/validation_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../core/extensions/string_extensions.dart';
import '../../core/utils/app_date_utils.dart';
import '../../core/utils/search_match_utils.dart';
import '../../data/models/income.dart';
import '../../data/models/income/income_filter.dart';
import '../../data/models/income/income_input.dart';
import '../../data/models/income/income_list_item.dart';
import '../../data/repositories/income_repository.dart';
import '../image/image_service.dart';
import '../payment_account/payment_account_service.dart';
import '../settings/settings_service.dart';

class IncomeService extends GetxService with BaseService {
  IncomeService(
    this._incomes,
    this._accounts,
    this._images,
    this._settings,
  );

  final IncomeRepository _incomes;
  final PaymentAccountService _accounts;
  final ImageService _images;
  final SettingsService _settings;

  int? get _profileId => _settings.activeProfileId;

  Future<ServiceResult<Income>> create(IncomeInput input) async {
    return guard(() async {
      _validateInput(input);
      final profileId = _requireProfileId();
      await _validateAccount(input.accountId, profileId);

      final income = Income()
        ..amount = input.amount
        ..source = input.source.trim()
        ..accountId = input.accountId
        ..date = input.date
        ..notes = input.notes?.trim().isEmpty == true ? null : input.notes?.trim()
        ..imagePaths = List.of(input.imagePaths)
        ..profileId = profileId
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      final id = await _incomes.put(income);
      income.id = id;
      return income;
    });
  }

  Future<ServiceResult<Income>> update(int id, IncomeInput input) async {
    return guard(() async {
      _validateInput(input);
      final profileId = _requireProfileId();
      final existing = await _getOwnedIncome(id, profileId);
      await _validateAccount(input.accountId, profileId);

      existing
        ..amount = input.amount
        ..source = input.source.trim()
        ..accountId = input.accountId
        ..date = input.date
        ..notes = input.notes?.trim().isEmpty == true ? null : input.notes?.trim()
        ..imagePaths = List.of(input.imagePaths)
        ..updatedAt = DateTime.now();

      await _incomes.put(existing);
      return existing;
    });
  }

  Future<ServiceResult<Income>> duplicate(int id) async {
    final profileId = _profileId;
    if (profileId == null) {
      return ServiceResult.failure(userMessage: 'No active profile');
    }
    try {
      final source = await _getOwnedIncome(id, profileId);
      return create(
        IncomeInput(
          amount: source.amount,
          source: source.source,
          accountId: source.accountId,
          date: DateTime.now(),
          notes: source.notes,
          imagePaths: List.of(source.imagePaths),
        ),
      );
    } on AppException catch (error) {
      return ServiceResult.failure(
        userMessage: error.message,
        errorCode: error.code,
        exception: error,
      );
    } catch (error, stackTrace) {
      log.e('Duplicate income failed', error: error, stackTrace: stackTrace);
      return ServiceResult.failure(userMessage: 'Could not duplicate income');
    }
  }

  Future<ServiceResult<void>> softDelete(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final income = await _getOwnedIncome(id, profileId);
      income
        ..isDeleted = true
        ..deletedAt = DateTime.now()
        ..updatedAt = DateTime.now();
      await _incomes.put(income);
    });
  }

  Future<ServiceResult<void>> restore(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final income = await _incomes.getOrThrow(id);
      if (income.profileId != profileId) {
        throw const NotFoundException(message: 'Income not found');
      }
      income
        ..isDeleted = false
        ..deletedAt = null
        ..updatedAt = DateTime.now();
      await _incomes.put(income);
    });
  }

  Future<ServiceResult<void>> permanentDelete(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final income = await _incomes.getOrThrow(id);
      if (income.profileId != profileId || !income.isDeleted) {
        throw const NotFoundException(message: 'Income not in trash');
      }
      await _images.deleteImages(income.imagePaths);
      await _incomes.deleteById(id);
    });
  }

  Future<Income?> getById(int id) async {
    final profileId = _profileId;
    if (profileId == null) return null;
    final income = await _incomes.findById(id);
    if (income == null || income.profileId != profileId) return null;
    return income;
  }

  Future<List<IncomeListItem>> listActive({IncomeFilter filter = IncomeFilter.empty}) async {
    final profileId = _profileId;
    if (profileId == null) return [];

    final accounts = await _accounts.getActiveAccounts();
    final accountMap = {for (final a in accounts) a.id: a};

    var records = await _incomes.findActiveByProfile(profileId);
    records = _applyFilter(records, filter, accountMap);

    return records.map((income) => _toListItem(income, accountMap)).toList();
  }

  Future<List<IncomeListItem>> listTrash() async {
    final profileId = _profileId;
    if (profileId == null) return [];

    final accounts = await _accounts.getActiveAccounts();
    final accountMap = {for (final a in accounts) a.id: a};
    final records = await _incomes.findDeletedByProfile(profileId);
    return records.map((income) => _toListItem(income, accountMap)).toList();
  }

  Future<List<Income>> listActiveRaw() async {
    final profileId = _profileId;
    if (profileId == null) return [];
    return _incomes.findActiveByProfile(profileId);
  }

  String sourceLabel(String source) {
    if (IncomeSources.isPredefinedKey(source)) {
      final key = IncomeSources.labelKeys[source];
      return key != null ? key.tr : source;
    }
    return source;
  }

  IncomeListItem _toListItem(Income income, Map<int, dynamic> accountMap) {
    final account = accountMap[income.accountId];
    return IncomeListItem(
      income: income,
      sourceLabel: sourceLabel(income.source),
      sourceColorHex: IncomeSources.colorHexFor(
        IncomeSources.isPredefinedKey(income.source) ? income.source : IncomeSources.custom,
      ),
      accountName: account?.name ?? 'Unknown',
    );
  }

  List<Income> _applyFilter(
    List<Income> records,
    IncomeFilter filter,
    Map<int, dynamic> accountMap,
  ) {
    var result = records;

    if (filter.source != null) {
      result = result.where((e) => e.source == filter.source).toList();
    }
    if (filter.accountId != null) {
      result = result.where((e) => e.accountId == filter.accountId).toList();
    }

    DateRange? range = AppDateUtils.resolveFilterRange(
      period: filter.datePeriod,
      customRange: filter.customRange,
    );
    if (range != null) {
      result = result.where((e) => range.contains(e.date)).toList();
    }

    final query = filter.searchQuery.trim();
    if (query.isNotEmpty) {
      result = result.where((e) {
        final account = accountMap[e.accountId];
        return SearchMatchUtils.matches(
          query,
          [
            e.amount.toString(),
            e.amount.toStringAsFixed(2),
            e.notes ?? '',
            sourceLabel(e.source),
            e.source,
            account?.name ?? '',
          ],
          date: e.date,
        );
      }).toList();
    }

    return result;
  }

  void _validateInput(IncomeInput input) {
    if (input.amount < ValidationConstants.minAmount ||
        input.amount > ValidationConstants.maxAmount) {
      throw const ValidationException(
        message: 'Enter a valid amount',
        field: 'amount',
      );
    }
    if (input.source.isBlank) {
      throw const ValidationException(
        message: 'Select or enter an income source',
        field: 'source',
      );
    }
    if (input.source.length > AppConstants.maxNameLength) {
      throw ValidationException(
        message: 'Source must be at most ${AppConstants.maxNameLength} characters',
        field: 'source',
      );
    }
    if (input.notes != null && input.notes!.length > AppConstants.maxNotesLength) {
      throw ValidationException(
        message: 'Notes must be at most ${AppConstants.maxNotesLength} characters',
        field: 'notes',
      );
    }
    if (input.imagePaths.length > AppConstants.maxImagesPerTransaction) {
      throw const ValidationException(
        message: 'Maximum 5 images allowed',
        field: 'images',
      );
    }
  }

  Future<void> _validateAccount(int accountId, int profileId) async {
    final account = await _accounts.getById(accountId);
    if (account == null || account.profileId != profileId) {
      throw const ValidationException(
        message: 'Select a valid payment account',
        field: 'account',
      );
    }
  }

  int _requireProfileId() {
    final id = _profileId;
    if (id == null) {
      throw const NotFoundException(
        message: 'No active profile',
        code: 'PROFILE_NOT_FOUND',
      );
    }
    return id;
  }

  Future<Income> _getOwnedIncome(int id, int profileId) async {
    final income = await _incomes.getOrThrow(id);
    if (income.profileId != profileId || income.isDeleted) {
      throw const NotFoundException(message: 'Income not found');
    }
    return income;
  }
}
