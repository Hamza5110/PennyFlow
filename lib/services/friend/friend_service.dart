import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/friend_constants.dart';
import '../../core/constants/validation_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../core/extensions/string_extensions.dart';
import '../../core/utils/app_date_utils.dart';
import '../../core/utils/search_match_utils.dart';
import '../../data/models/friend.dart';
import '../../data/models/friend/friend_input.dart';
import '../../data/models/friend/friend_models.dart';
import '../../data/models/friend/friend_transaction_input.dart';
import '../../data/models/friend/repayment_input.dart';
import '../../data/models/friend_transaction.dart';
import '../../data/models/repayment.dart';
import '../../data/repositories/friend_repository.dart';
import '../../data/repositories/friend_transaction_repository.dart';
import '../../data/repositories/repayment_repository.dart';
import '../image/image_service.dart';
import '../reminder/reminder_service.dart';
import '../settings/settings_service.dart';

class FriendService extends GetxService with BaseService {
  FriendService(
    this._friends,
    this._transactions,
    this._repayments,
    this._images,
    this._settings,
  );

  final FriendRepository _friends;
  final FriendTransactionRepository _transactions;
  final RepaymentRepository _repayments;
  final ImageService _images;
  final SettingsService _settings;

  int? get _profileId => _settings.activeProfileId;

  Future<List<FriendListItem>> listFriends() async {
    final profileId = _profileId;
    if (profileId == null) return [];

    final friends = await _friends.findByProfile(profileId);
    final items = <FriendListItem>[];
    for (final friend in friends) {
      items.add(await _toFriendListItem(friend, profileId));
    }
    return items;
  }

  Future<FriendLedgerSummary> getLedgerSummary() async {
    final profileId = _profileId;
    if (profileId == null) {
      return const FriendLedgerSummary(
        moneyLent: 0,
        moneyBorrowed: 0,
        pendingReceive: 0,
        pendingPay: 0,
      );
    }

    final transactions = await _transactions.findActiveByProfile(profileId);
    var moneyLent = 0.0;
    var moneyBorrowed = 0.0;
    var pendingReceive = 0.0;
    var pendingPay = 0.0;

    for (final txn in transactions) {
      final remaining = await remainingBalance(txn.id);
      if (txn.type == FriendTransactionTypes.given) {
        moneyLent += txn.amount;
        pendingReceive += remaining;
      } else {
        moneyBorrowed += txn.amount;
        pendingPay += remaining;
      }
    }

    return FriendLedgerSummary(
      moneyLent: moneyLent,
      moneyBorrowed: moneyBorrowed,
      pendingReceive: pendingReceive,
      pendingPay: pendingPay,
    );
  }

  Future<Friend?> getFriendById(int id) async {
    final profileId = _profileId;
    if (profileId == null) return null;
    final friend = await _friends.findById(id);
    if (friend == null || friend.profileId != profileId) return null;
    return friend;
  }

  Future<ServiceResult<Friend>> createFriend(FriendInput input) async {
    return guard(() async {
      final profileId = _requireProfileId();
      _validateFriendInput(input);
      await _ensureUniqueFriendName(profileId, input.name);

      final friend = Friend()
        ..name = input.name.trim()
        ..phone = input.phone?.trim().isEmpty == true ? null : input.phone?.trim()
        ..profileId = profileId;

      final id = await _friends.put(friend);
      friend.id = id;
      return friend;
    });
  }

  Future<ServiceResult<Friend>> updateFriend(int id, FriendInput input) async {
    return guard(() async {
      final profileId = _requireProfileId();
      _validateFriendInput(input);
      final existing = await _getOwnedFriend(id, profileId);
      await _ensureUniqueFriendName(profileId, input.name, excludeId: id);

      existing
        ..name = input.name.trim()
        ..phone =
            input.phone?.trim().isEmpty == true ? null : input.phone?.trim();

      await _friends.put(existing);
      return existing;
    });
  }

  Future<ServiceResult<void>> deleteFriend(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      await _getOwnedFriend(id, profileId);
      final count = await _transactions.countActiveByFriend(id);
      if (count > 0) {
        throw const ValidationException(
          message: 'Friend has transactions and cannot be deleted',
          field: 'friend',
        );
      }
      await _friends.deleteById(id);
    });
  }

  Future<List<FriendTransactionListItem>> listTransactions({
    int? friendId,
    FriendFilter filter = FriendFilter.empty,
  }) async {
    final profileId = _profileId;
    if (profileId == null) return [];

    var transactions = friendId == null
        ? await _transactions.findActiveByProfile(profileId)
        : await _transactions.findActiveByFriend(friendId);

    transactions = await _applyTransactionFilter(transactions, filter, profileId);
    final items = <FriendTransactionListItem>[];
    for (final txn in transactions) {
      final friend = await _friends.findById(txn.friendId);
      final repaid = await _repayments.sumByTransaction(txn.id);
      items.add(
        FriendTransactionListItem(
          transaction: txn,
          friendName: friend?.name ?? 'Unknown',
          remainingBalance: (txn.amount - repaid).clamp(0, txn.amount),
          repaymentTotal: repaid,
        ),
      );
    }
    return items;
  }

  Future<List<FriendTransactionListItem>> listTrash() async {
    final profileId = _profileId;
    if (profileId == null) return [];
    final transactions = await _transactions.findDeletedByProfile(profileId);
    final items = <FriendTransactionListItem>[];
    for (final txn in transactions) {
      final friend = await _friends.findById(txn.friendId);
      final repaid = await _repayments.sumByTransaction(txn.id);
      items.add(
        FriendTransactionListItem(
          transaction: txn,
          friendName: friend?.name ?? 'Unknown',
          remainingBalance: (txn.amount - repaid).clamp(0, txn.amount),
          repaymentTotal: repaid,
        ),
      );
    }
    return items;
  }

  Future<FriendTransaction?> getTransactionById(int id) async {
    final profileId = _profileId;
    if (profileId == null) return null;
    final txn = await _transactions.findById(id);
    if (txn == null || txn.profileId != profileId) return null;
    return txn;
  }

  Future<List<Repayment>> getRepayments(int transactionId) =>
      _repayments.findByTransaction(transactionId);

  Future<double> remainingBalance(int transactionId) async {
    final txn = await _transactions.findById(transactionId);
    if (txn == null) return 0;
    final repaid = await _repayments.sumByTransaction(transactionId);
    return (txn.amount - repaid).clamp(0, txn.amount);
  }

  Future<ServiceResult<FriendTransaction>> createTransaction(
    FriendTransactionInput input,
  ) async {
    return guard(() async {
      final profileId = _requireProfileId();
      _validateTransactionInput(input);
      await _getOwnedFriend(input.friendId, profileId);

      final txn = FriendTransaction()
        ..friendId = input.friendId
        ..type = input.type
        ..amount = input.amount
        ..date = input.date
        ..dueDate = input.dueDate
        ..notes = input.notes?.trim().isEmpty == true ? null : input.notes?.trim()
        ..imagePaths = List.of(input.imagePaths)
        ..status = FriendTransactionStatus.pending
        ..profileId = profileId
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      final id = await _transactions.put(txn);
      txn.id = id;
      await _syncReminder(txn);
      return txn;
    });
  }

  Future<ServiceResult<FriendTransaction>> updateTransaction(
    int id,
    FriendTransactionInput input,
  ) async {
    return guard(() async {
      final profileId = _requireProfileId();
      _validateTransactionInput(input);
      final existing = await _getOwnedTransaction(id, profileId);
      await _getOwnedFriend(input.friendId, profileId);

      existing
        ..friendId = input.friendId
        ..type = input.type
        ..amount = input.amount
        ..date = input.date
        ..dueDate = input.dueDate
        ..notes = input.notes?.trim().isEmpty == true ? null : input.notes?.trim()
        ..imagePaths = List.of(input.imagePaths)
        ..updatedAt = DateTime.now();

      await _refreshStatus(existing);
      await _transactions.put(existing);
      await _syncReminder(existing);
      return existing;
    });
  }

  Future<ServiceResult<Repayment>> addRepayment(
    int transactionId,
    RepaymentInput input,
  ) async {
    return guard(() async {
      final profileId = _requireProfileId();
      final txn = await _getOwnedTransaction(transactionId, profileId);
      _validateRepaymentInput(input);

      final remaining = await remainingBalance(transactionId);
      if (input.amount > remaining) {
        throw ValidationException(
          message: 'Repayment cannot exceed remaining balance ($remaining)',
          field: 'amount',
        );
      }

      final repayment = Repayment()
        ..friendTransactionId = transactionId
        ..amount = input.amount
        ..date = input.date
        ..note = input.note?.trim().isEmpty == true ? null : input.note?.trim()
        ..imagePaths = List.of(input.imagePaths)
        ..createdAt = DateTime.now();

      final repaymentId = await _repayments.put(repayment);
      repayment.id = repaymentId;

      await _refreshStatus(txn);
      await _transactions.put(txn);
      await _syncReminder(txn);
      return repayment;
    });
  }

  Future<ServiceResult<void>> softDeleteTransaction(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final txn = await _getOwnedTransaction(id, profileId);
      txn
        ..isDeleted = true
        ..deletedAt = DateTime.now()
        ..updatedAt = DateTime.now();
      await _transactions.put(txn);
      await _syncReminder(txn);
    });
  }

  Future<ServiceResult<void>> restoreTransaction(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final txn = await _transactions.getOrThrow(id);
      if (txn.profileId != profileId) {
        throw const NotFoundException(message: 'Transaction not found');
      }
      txn
        ..isDeleted = false
        ..deletedAt = null
        ..updatedAt = DateTime.now();
      await _transactions.put(txn);
      await _syncReminder(txn);
    });
  }

  Future<ServiceResult<void>> permanentDeleteTransaction(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final txn = await _transactions.getOrThrow(id);
      if (txn.profileId != profileId || !txn.isDeleted) {
        throw const NotFoundException(message: 'Transaction not in trash');
      }
      await _images.deleteImages(txn.imagePaths);
      final repayments = await _repayments.findByTransaction(id);
      for (final repayment in repayments) {
        await _images.deleteImages(repayment.imagePaths);
      }
      await _repayments.deleteByTransaction(id);
      await _transactions.deleteById(id);
    });
  }

  Future<void> _syncReminder(FriendTransaction txn) async {
    if (!Get.isRegistered<ReminderService>()) return;
    await Get.find<ReminderService>().syncFriendTransaction(txn);
  }

  Future<void> _refreshStatus(FriendTransaction txn) async {
    final repaid = await _repayments.sumByTransaction(txn.id);
    if (repaid <= 0) {
      txn.status = FriendTransactionStatus.pending;
    } else if (repaid >= txn.amount) {
      txn.status = FriendTransactionStatus.completed;
    } else {
      txn.status = FriendTransactionStatus.partiallyPaid;
    }
  }

  Future<FriendListItem> _toFriendListItem(Friend friend, int profileId) async {
    final txns = await _transactions.findActiveByFriend(friend.id);
    var pendingReceive = 0.0;
    var pendingPay = 0.0;
    for (final txn in txns) {
      final remaining = await remainingBalance(txn.id);
      if (txn.type == FriendTransactionTypes.given) {
        pendingReceive += remaining;
      } else {
        pendingPay += remaining;
      }
    }
    return FriendListItem(
      friend: friend,
      netPendingBalance: pendingReceive - pendingPay,
      pendingReceive: pendingReceive,
      pendingPay: pendingPay,
      transactionCount: txns.length,
    );
  }

  Future<List<FriendTransaction>> _applyTransactionFilter(
    List<FriendTransaction> transactions,
    FriendFilter filter,
    int profileId,
  ) async {
    var result = transactions;

    if (filter.status != null) {
      result = result.where((t) => t.status == filter.status).toList();
    }

    if (filter.friendId != null) {
      result = result.where((t) => t.friendId == filter.friendId).toList();
    }

    DateRange? range = AppDateUtils.resolveFilterRange(
      period: filter.datePeriod,
      customRange: filter.customRange,
    );
    if (range != null) {
      result = result.where((t) => range.contains(t.date)).toList();
    }

    final query = filter.searchQuery.trim();
    if (query.isNotEmpty) {
      final filtered = <FriendTransaction>[];
      for (final txn in result) {
        final friend = await _friends.findById(txn.friendId);
        if (SearchMatchUtils.matches(
          query,
          [
            txn.amount.toString(),
            txn.amount.toStringAsFixed(2),
            txn.notes ?? '',
            friend?.name ?? '',
            txn.type,
            txn.status,
          ],
          date: txn.date,
        )) {
          filtered.add(txn);
        }
      }
      result = filtered;
    }

    return result;
  }

  void _validateFriendInput(FriendInput input) {
    final name = input.name.trim();
    if (name.isBlank) {
      throw const ValidationException(message: 'Name is required', field: 'name');
    }
    if (name.length > ValidationConstants.maxFriendNameLength) {
      throw ValidationException(
        message:
            'Name must be at most ${ValidationConstants.maxFriendNameLength} characters',
        field: 'name',
      );
    }
  }

  void _validateTransactionInput(FriendTransactionInput input) {
    if (input.amount < ValidationConstants.minAmount ||
        input.amount > ValidationConstants.maxAmount) {
      throw const ValidationException(
        message: 'Enter a valid amount',
        field: 'amount',
      );
    }
    if (input.type != FriendTransactionTypes.given &&
        input.type != FriendTransactionTypes.received) {
      throw const ValidationException(
        message: 'Select a valid transaction type',
        field: 'type',
      );
    }
    if (input.notes != null &&
        input.notes!.length > ValidationConstants.maxNotesLength) {
      throw ValidationException(
        message:
            'Notes must be at most ${ValidationConstants.maxNotesLength} characters',
        field: 'notes',
      );
    }
    if (input.imagePaths.length > 5) {
      throw const ValidationException(
        message: 'Maximum 5 images allowed',
        field: 'images',
      );
    }
  }

  void _validateRepaymentInput(RepaymentInput input) {
    if (input.amount < ValidationConstants.minAmount ||
        input.amount > ValidationConstants.maxAmount) {
      throw const ValidationException(
        message: 'Enter a valid amount',
        field: 'amount',
      );
    }
    if (input.note != null &&
        input.note!.length > ValidationConstants.maxNotesLength) {
      throw ValidationException(
        message:
            'Notes must be at most ${ValidationConstants.maxNotesLength} characters',
        field: 'note',
      );
    }
    if (input.imagePaths.length > 5) {
      throw const ValidationException(
        message: 'Maximum 5 images allowed',
        field: 'images',
      );
    }
  }

  Future<void> _ensureUniqueFriendName(
    int profileId,
    String name, {
    int? excludeId,
  }) async {
    final existing = await _friends.findByName(profileId, name.trim());
    if (existing != null && existing.id != excludeId) {
      throw const ValidationException(
        message: 'A friend with this name already exists',
        code: 'FRIEND_NAME_EXISTS',
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

  Future<Friend> _getOwnedFriend(int id, int profileId) async {
    final friend = await _friends.getOrThrow(id);
    if (friend.profileId != profileId) {
      throw const NotFoundException(message: 'Friend not found');
    }
    return friend;
  }

  Future<FriendTransaction> _getOwnedTransaction(int id, int profileId) async {
    final txn = await _transactions.getOrThrow(id);
    if (txn.profileId != profileId || txn.isDeleted) {
      throw const NotFoundException(message: 'Transaction not found');
    }
    return txn;
  }
}
