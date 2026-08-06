import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/payment_account_types.dart';
import '../../core/constants/validation_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../core/extensions/string_extensions.dart';
import '../../data/models/payment_account.dart';
import '../../data/models/payment_account/payment_account_input.dart';
import '../../data/models/payment_account/payment_account_list_item.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/income_repository.dart';
import '../../data/repositories/payment_account_repository.dart';
import '../settings/settings_service.dart';
import '../cache/profile_lookup_cache_service.dart';

/// Default payment accounts (FR-071).
abstract final class PaymentAccountDefaults {
  static const List<({String name, String type})> items = [
    (name: 'Cash', type: PaymentAccountTypes.cash),
    (name: 'Bank Account', type: PaymentAccountTypes.bank),
    (name: 'EasyPaisa', type: PaymentAccountTypes.easypaisa),
    (name: 'JazzCash', type: PaymentAccountTypes.jazzcash),
    (name: 'Credit Card', type: PaymentAccountTypes.creditCard),
  ];
}

class PaymentAccountService extends GetxService with BaseService {
  PaymentAccountService(
    this._repository,
    this._expenses,
    this._incomes,
    this._settings,
  );

  final PaymentAccountRepository _repository;
  final ExpenseRepository _expenses;
  final IncomeRepository _incomes;
  final SettingsService _settings;

  Future<PaymentAccountService> init() async {
    await _ensureDefaults();
    return this;
  }

  int? get _profileId => _settings.activeProfileId;

  Future<void> _ensureDefaults() async {
    final profileId = _profileId;
    if (profileId == null) return;

    final count = await _repository.countByProfile(profileId);
    if (count > 0) return;

    await _seedDefaults(profileId);
    log.i('Seeded default payment accounts for profile $profileId');
  }

  Future<void> ensureDefaultsForProfile(int profileId) async {
    final count = await _repository.countByProfile(profileId);
    if (count > 0) return;
    await _seedDefaults(profileId);
  }

  Future<void> _seedDefaults(int profileId) async {
    await _repository.db.writeTxn(() async {
      for (final item in PaymentAccountDefaults.items) {
        final account = PaymentAccount()
          ..name = item.name
          ..type = item.type
          ..isDefault = true
          ..profileId = profileId;
        await _repository.collection.put(account);
      }
    });
  }

  Future<List<PaymentAccount>> getActiveAccounts() async {
    final profileId = _profileId;
    if (profileId == null) return [];
    await _ensureDefaults();
    return _repository.findActiveByProfile(profileId);
  }

  Future<List<PaymentAccountListItem>> listActiveWithBalances() async {
    final profileId = _profileId;
    if (profileId == null) return [];
    await _ensureDefaults();
    final accounts = await _repository.findActiveByProfile(profileId);
    return _mapWithBalances(accounts, profileId);
  }

  Future<List<PaymentAccountListItem>> listArchivedWithBalances() async {
    final profileId = _profileId;
    if (profileId == null) return [];
    final accounts = await _repository.findArchivedByProfile(profileId);
    return _mapWithBalances(accounts, profileId);
  }

  Future<PaymentAccount?> getById(int id) => _repository.findById(id);

  Future<int> countUsage(int accountId) async {
    final profileId = _profileId;
    if (profileId == null) return 0;
    final expenses = await _expenses.countActiveByAccount(accountId, profileId);
    final incomes = await _incomes.countActiveByAccount(accountId, profileId);
    return expenses + incomes;
  }

  Future<double> calculateBalance(int accountId) async {
    final profileId = _profileId;
    if (profileId == null) return 0;
    final account = await _repository.findById(accountId);
    if (account == null || account.profileId != profileId) return 0;

    final incomeTotal =
        await _incomes.sumActiveByAccount(accountId, profileId);
    final expenseTotal =
        await _expenses.sumActiveByAccount(accountId, profileId);
    return account.openingBalance + incomeTotal - expenseTotal;
  }

  String typeLabel(String type) {
    if (PaymentAccountTypes.isPredefinedKey(type)) {
      final key = PaymentAccountTypes.labelKeys[type];
      return key != null ? key.tr : type;
    }
    return type;
  }

  Future<ServiceResult<PaymentAccount>> create(PaymentAccountInput input) async {
    return guard(() async {
      final profileId = _requireProfileId();
      _validateInput(input);
      await _ensureUniqueName(profileId, input.name);

      final account = PaymentAccount()
        ..name = input.name.trim()
        ..type = input.type
        ..openingBalance = input.openingBalance
        ..isDefault = false
        ..profileId = profileId;

      final id = await _repository.put(account);
      account.id = id;
      _invalidateLookupCache();
      return account;
    });
  }

  Future<ServiceResult<PaymentAccount>> update(
    int id,
    PaymentAccountInput input,
  ) async {
    return guard(() async {
      final profileId = _requireProfileId();
      _validateInput(input);
      final existing = await _getOwnedAccount(id, profileId);
      await _ensureUniqueName(profileId, input.name, excludeId: id);

      existing
        ..name = input.name.trim()
        ..type = input.type
        ..openingBalance = input.openingBalance;

      await _repository.put(existing);
      _invalidateLookupCache();
      return existing;
    });
  }

  Future<ServiceResult<void>> archive(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final account = await _getOwnedAccount(id, profileId);
      account.isArchived = true;
      await _repository.put(account);
      _invalidateLookupCache();
    });
  }

  Future<ServiceResult<void>> unarchive(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final account = await _getOwnedAccount(id, profileId);
      account.isArchived = false;
      await _repository.put(account);
      _invalidateLookupCache();
    });
  }

  Future<ServiceResult<void>> delete(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final account = await _getOwnedAccount(id, profileId);

      if (account.isDefault) {
        throw const ValidationException(
          message: 'Default accounts cannot be deleted',
          code: 'ACCOUNT_DEFAULT',
          field: 'account',
        );
      }

      final usage = await countUsage(id);
      if (usage > 0) {
        throw ValidationException(
          message:
              'Account has $usage transaction(s). Archive it instead of deleting.',
          code: 'ACCOUNT_IN_USE',
          field: 'account',
        );
      }

      await _repository.deleteById(id);
      _invalidateLookupCache();
    });
  }

  void _invalidateLookupCache() {
    if (Get.isRegistered<ProfileLookupCacheService>()) {
      Get.find<ProfileLookupCacheService>().invalidate();
    }
  }

  Future<List<PaymentAccountListItem>> _mapWithBalances(
    List<PaymentAccount> accounts,
    int profileId,
  ) async {
    final items = <PaymentAccountListItem>[];
    for (final account in accounts) {
      final expenseCount =
          await _expenses.countActiveByAccount(account.id, profileId);
      final incomeCount =
          await _incomes.countActiveByAccount(account.id, profileId);
      final incomeTotal =
          await _incomes.sumActiveByAccount(account.id, profileId);
      final expenseTotal =
          await _expenses.sumActiveByAccount(account.id, profileId);
      items.add(
        PaymentAccountListItem(
          account: account,
          balance: account.openingBalance + incomeTotal - expenseTotal,
          transactionCount: expenseCount + incomeCount,
        ),
      );
    }
    return items;
  }

  void _validateInput(PaymentAccountInput input) {
    final name = input.name.trim();
    if (name.isBlank) {
      throw const ValidationException(message: 'Name is required', field: 'name');
    }
    if (name.length > ValidationConstants.maxAccountNameLength) {
      throw ValidationException(
        message:
            'Name must be at most ${ValidationConstants.maxAccountNameLength} characters',
        field: 'name',
      );
    }
    if (!PaymentAccountTypes.isPredefinedKey(input.type) &&
        input.type != PaymentAccountTypes.custom) {
      throw const ValidationException(
        message: 'Select a valid account type',
        field: 'type',
      );
    }
    if (input.openingBalance < 0 ||
        input.openingBalance > ValidationConstants.maxAmount) {
      throw const ValidationException(
        message: 'Enter a valid opening balance',
        field: 'openingBalance',
      );
    }
  }

  Future<void> _ensureUniqueName(
    int profileId,
    String name, {
    int? excludeId,
  }) async {
    final existing = await _repository.findByName(profileId, name.trim());
    if (existing != null && existing.id != excludeId) {
      throw const ValidationException(
        message: 'An account with this name already exists',
        code: 'ACCOUNT_NAME_EXISTS',
        field: 'name',
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

  Future<PaymentAccount> _getOwnedAccount(int id, int profileId) async {
    final account = await _repository.getOrThrow(id);
    if (account.profileId != profileId) {
      throw const NotFoundException(message: 'Account not found');
    }
    return account;
  }
}
