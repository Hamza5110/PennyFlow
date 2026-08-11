import 'package:isar_community/isar.dart';

import '../../data/local/database/isar_database.dart';
import '../../data/models/budget.dart';
import '../../data/models/category.dart';
import '../../data/models/expense.dart';
import '../../data/models/friend.dart';
import '../../data/models/friend_transaction.dart';
import '../../data/models/income.dart';
import '../../data/models/payment_account.dart';
import '../../data/models/profile.dart';
import '../../data/models/recurring_template.dart';
import '../../data/models/reminder.dart';
import '../../data/models/repayment.dart';

/// Serializes active-profile Isar collections to JSON maps (FR-143).
class BackupSnapshotCodec {
  BackupSnapshotCodec(this._database);

  final IsarDatabase _database;

  Isar get _isar => _database.isar;

  Future<Map<String, dynamic>> exportProfile(int profileId) async {
    final profile = await _isar.profiles.get(profileId);
    if (profile == null) {
      throw StateError('Profile $profileId not found');
    }

    final expenses =
        await _isar.expenses.filter().profileIdEqualTo(profileId).findAll();
    final incomes =
        await _isar.incomes.filter().profileIdEqualTo(profileId).findAll();
    final categories =
        await _isar.categorys.filter().profileIdEqualTo(profileId).findAll();
    final accounts = await _isar.paymentAccounts
        .filter()
        .profileIdEqualTo(profileId)
        .findAll();
    final friends =
        await _isar.friends.filter().profileIdEqualTo(profileId).findAll();
    final transactions = await _isar.friendTransactions
        .filter()
        .profileIdEqualTo(profileId)
        .findAll();
    final transactionIds = transactions.map((e) => e.id).toSet();
    final repayments = await _isar.repayments
        .filter()
        .friendTransactionIdGreaterThan(0)
        .findAll();
    final profileRepayments = repayments
        .where((r) => transactionIds.contains(r.friendTransactionId))
        .toList();
    final budgets =
        await _isar.budgets.filter().profileIdEqualTo(profileId).findAll();
    final recurring = await _isar.recurringTemplates
        .filter()
        .profileIdEqualTo(profileId)
        .findAll();
    final reminders =
        await _isar.reminders.filter().profileIdEqualTo(profileId).findAll();

    return {
      'profile': _profileToMap(profile),
      'categories': categories.map(_categoryToMap).toList(),
      'paymentAccounts': accounts.map(_paymentAccountToMap).toList(),
      'expenses': expenses.map(_expenseToMap).toList(),
      'incomes': incomes.map(_incomeToMap).toList(),
      'friends': friends.map(_friendToMap).toList(),
      'friendTransactions': transactions.map(_friendTransactionToMap).toList(),
      'repayments': profileRepayments.map(_repaymentToMap).toList(),
      'budgets': budgets.map(_budgetToMap).toList(),
      'recurringTemplates': recurring.map(_recurringTemplateToMap).toList(),
      'reminders': reminders.map(_reminderToMap).toList(),
    };
  }

  Future<void> importProfile(
    Map<String, dynamic> data, {
    required int profileId,
    required bool overwrite,
  }) async {
    if (overwrite) {
      await clearProfileData(profileId);
    }

    await _database.writeTxn(() async {
      final profileMap = data['profile'] as Map<String, dynamic>;
      final profile = _profileFromMap(profileMap)..id = profileId;
      await _isar.profiles.put(profile);

      for (final raw in data['categories'] as List<dynamic>) {
        await _isar.categorys.put(_categoryFromMap(raw as Map<String, dynamic>));
      }
      for (final raw in data['paymentAccounts'] as List<dynamic>) {
        await _isar.paymentAccounts
            .put(_paymentAccountFromMap(raw as Map<String, dynamic>));
      }
      for (final raw in data['friends'] as List<dynamic>) {
        await _isar.friends.put(_friendFromMap(raw as Map<String, dynamic>));
      }
      for (final raw in data['expenses'] as List<dynamic>) {
        await _isar.expenses.put(_expenseFromMap(raw as Map<String, dynamic>));
      }
      for (final raw in data['incomes'] as List<dynamic>) {
        await _isar.incomes.put(_incomeFromMap(raw as Map<String, dynamic>));
      }
      for (final raw in data['friendTransactions'] as List<dynamic>) {
        await _isar.friendTransactions
            .put(_friendTransactionFromMap(raw as Map<String, dynamic>));
      }
      for (final raw in data['repayments'] as List<dynamic>) {
        await _isar.repayments
            .put(_repaymentFromMap(raw as Map<String, dynamic>));
      }
      for (final raw in data['budgets'] as List<dynamic>) {
        await _isar.budgets.put(_budgetFromMap(raw as Map<String, dynamic>));
      }
      for (final raw in data['recurringTemplates'] as List<dynamic>) {
        await _isar.recurringTemplates
            .put(_recurringTemplateFromMap(raw as Map<String, dynamic>));
      }
      for (final raw in data['reminders'] as List<dynamic>) {
        await _isar.reminders.put(_reminderFromMap(raw as Map<String, dynamic>));
      }
    });
  }

  Future<void> clearProfileData(int profileId) async {
    await _database.writeTxn(() async {
      final transactions = await _isar.friendTransactions
          .filter()
          .profileIdEqualTo(profileId)
          .findAll();
      for (final txn in transactions) {
        final repayments = await _isar.repayments
            .filter()
            .friendTransactionIdEqualTo(txn.id)
            .findAll();
        for (final repayment in repayments) {
          await _isar.repayments.delete(repayment.id);
        }
        await _isar.friendTransactions.delete(txn.id);
      }

      final friends =
          await _isar.friends.filter().profileIdEqualTo(profileId).findAll();
      for (final friend in friends) {
        await _isar.friends.delete(friend.id);
      }

      final expenses =
          await _isar.expenses.filter().profileIdEqualTo(profileId).findAll();
      for (final expense in expenses) {
        await _isar.expenses.delete(expense.id);
      }

      final incomes =
          await _isar.incomes.filter().profileIdEqualTo(profileId).findAll();
      for (final income in incomes) {
        await _isar.incomes.delete(income.id);
      }

      final budgets =
          await _isar.budgets.filter().profileIdEqualTo(profileId).findAll();
      for (final budget in budgets) {
        await _isar.budgets.delete(budget.id);
      }

      final recurring = await _isar.recurringTemplates
          .filter()
          .profileIdEqualTo(profileId)
          .findAll();
      for (final template in recurring) {
        await _isar.recurringTemplates.delete(template.id);
      }

      final reminders =
          await _isar.reminders.filter().profileIdEqualTo(profileId).findAll();
      for (final reminder in reminders) {
        await _isar.reminders.delete(reminder.id);
      }

      final categories =
          await _isar.categorys.filter().profileIdEqualTo(profileId).findAll();
      for (final category in categories) {
        await _isar.categorys.delete(category.id);
      }

      final accounts = await _isar.paymentAccounts
          .filter()
          .profileIdEqualTo(profileId)
          .findAll();
      for (final account in accounts) {
        await _isar.paymentAccounts.delete(account.id);
      }
    });
  }

  Future<bool> profileHasData(int profileId) async {
    final expenseCount =
        await _isar.expenses.filter().profileIdEqualTo(profileId).count();
    if (expenseCount > 0) return true;
    final incomeCount =
        await _isar.incomes.filter().profileIdEqualTo(profileId).count();
    if (incomeCount > 0) return true;
    final txnCount = await _isar.friendTransactions
        .filter()
        .profileIdEqualTo(profileId)
        .count();
    return txnCount > 0;
  }

  Map<String, dynamic> _profileToMap(Profile profile) => {
        'id': profile.id,
        'name': profile.name,
        'googleAccountEmail': profile.googleAccountEmail,
        'currencyCode': profile.currencyCode,
        'appLockEnabled': profile.appLockEnabled,
        'pinHash': profile.pinHash,
        'biometricEnabled': profile.biometricEnabled,
        'createdAt': profile.createdAt.toIso8601String(),
      };

  Profile _profileFromMap(Map<String, dynamic> map) => Profile()
    ..id = map['id'] as int
    ..name = map['name'] as String
    ..googleAccountEmail = map['googleAccountEmail'] as String?
    ..currencyCode = map['currencyCode'] as String? ?? 'PKR'
    ..appLockEnabled = map['appLockEnabled'] as bool? ?? false
    ..pinHash = map['pinHash'] as String?
    ..biometricEnabled = map['biometricEnabled'] as bool? ?? false
    ..createdAt = DateTime.parse(map['createdAt'] as String);

  Map<String, dynamic> _categoryToMap(Category category) => {
        'id': category.id,
        'name': category.name,
        'colorHex': category.colorHex,
        'iconKey': category.iconKey,
        'isDefault': category.isDefault,
        'profileId': category.profileId,
      };

  Category _categoryFromMap(Map<String, dynamic> map) => Category()
    ..id = map['id'] as int
    ..name = map['name'] as String
    ..colorHex = map['colorHex'] as String
    ..iconKey = map['iconKey'] as String
    ..isDefault = map['isDefault'] as bool? ?? false
    ..profileId = map['profileId'] as int;

  Map<String, dynamic> _paymentAccountToMap(PaymentAccount account) => {
        'id': account.id,
        'name': account.name,
        'type': account.type,
        'openingBalance': account.openingBalance,
        'isDefault': account.isDefault,
        'isArchived': account.isArchived,
        'profileId': account.profileId,
      };

  PaymentAccount _paymentAccountFromMap(Map<String, dynamic> map) =>
      PaymentAccount()
        ..id = map['id'] as int
        ..name = map['name'] as String
        ..type = map['type'] as String
        ..openingBalance = (map['openingBalance'] as num?)?.toDouble() ?? 0
        ..isDefault = map['isDefault'] as bool? ?? false
        ..isArchived = map['isArchived'] as bool? ?? false
        ..profileId = map['profileId'] as int;

  Map<String, dynamic> _expenseToMap(Expense expense) => {
        'id': expense.id,
        'amount': expense.amount,
        'categoryId': expense.categoryId,
        'accountId': expense.accountId,
        'date': expense.date.toIso8601String(),
        'notes': expense.notes,
        'tags': expense.tags,
        'location': expense.location,
        'receiptImagePaths': expense.receiptImagePaths,
        'isDeleted': expense.isDeleted,
        'deletedAt': expense.deletedAt?.toIso8601String(),
        'recurringTemplateId': expense.recurringTemplateId,
        'createdAt': expense.createdAt.toIso8601String(),
        'updatedAt': expense.updatedAt.toIso8601String(),
        'profileId': expense.profileId,
      };

  Expense _expenseFromMap(Map<String, dynamic> map) => Expense()
    ..id = map['id'] as int
    ..amount = (map['amount'] as num).toDouble()
    ..categoryId = map['categoryId'] as int
    ..accountId = map['accountId'] as int
    ..date = DateTime.parse(map['date'] as String)
    ..notes = map['notes'] as String?
    ..tags = List<String>.from(map['tags'] as List<dynamic>? ?? [])
    ..location = map['location'] as String?
    ..receiptImagePaths =
        List<String>.from(map['receiptImagePaths'] as List<dynamic>? ?? [])
    ..isDeleted = map['isDeleted'] as bool? ?? false
    ..deletedAt = map['deletedAt'] != null
        ? DateTime.parse(map['deletedAt'] as String)
        : null
    ..recurringTemplateId = map['recurringTemplateId'] as int?
    ..createdAt = DateTime.parse(map['createdAt'] as String)
    ..updatedAt = DateTime.parse(map['updatedAt'] as String)
    ..profileId = map['profileId'] as int;

  Map<String, dynamic> _incomeToMap(Income income) => {
        'id': income.id,
        'amount': income.amount,
        'source': income.source,
        'accountId': income.accountId,
        'date': income.date.toIso8601String(),
        'notes': income.notes,
        'imagePaths': income.imagePaths,
        'isDeleted': income.isDeleted,
        'deletedAt': income.deletedAt?.toIso8601String(),
        'recurringTemplateId': income.recurringTemplateId,
        'createdAt': income.createdAt.toIso8601String(),
        'updatedAt': income.updatedAt.toIso8601String(),
        'profileId': income.profileId,
      };

  Income _incomeFromMap(Map<String, dynamic> map) => Income()
    ..id = map['id'] as int
    ..amount = (map['amount'] as num).toDouble()
    ..source = map['source'] as String
    ..accountId = map['accountId'] as int
    ..date = DateTime.parse(map['date'] as String)
    ..notes = map['notes'] as String?
    ..imagePaths = List<String>.from(map['imagePaths'] as List<dynamic>? ?? [])
    ..isDeleted = map['isDeleted'] as bool? ?? false
    ..deletedAt = map['deletedAt'] != null
        ? DateTime.parse(map['deletedAt'] as String)
        : null
    ..recurringTemplateId = map['recurringTemplateId'] as int?
    ..createdAt = DateTime.parse(map['createdAt'] as String)
    ..updatedAt = DateTime.parse(map['updatedAt'] as String)
    ..profileId = map['profileId'] as int;

  Map<String, dynamic> _friendToMap(Friend friend) => {
        'id': friend.id,
        'name': friend.name,
        'phone': friend.phone,
        'profileId': friend.profileId,
      };

  Friend _friendFromMap(Map<String, dynamic> map) => Friend()
    ..id = map['id'] as int
    ..name = map['name'] as String
    ..phone = map['phone'] as String?
    ..profileId = map['profileId'] as int;

  Map<String, dynamic> _friendTransactionToMap(FriendTransaction txn) => {
        'id': txn.id,
        'friendId': txn.friendId,
        'type': txn.type,
        'amount': txn.amount,
        'date': txn.date.toIso8601String(),
        'dueDate': txn.dueDate?.toIso8601String(),
        'notes': txn.notes,
        'imagePaths': txn.imagePaths,
        'status': txn.status,
        'isDeleted': txn.isDeleted,
        'deletedAt': txn.deletedAt?.toIso8601String(),
        'createdAt': txn.createdAt.toIso8601String(),
        'updatedAt': txn.updatedAt.toIso8601String(),
        'profileId': txn.profileId,
      };

  FriendTransaction _friendTransactionFromMap(Map<String, dynamic> map) =>
      FriendTransaction()
        ..id = map['id'] as int
        ..friendId = map['friendId'] as int
        ..type = map['type'] as String
        ..amount = (map['amount'] as num).toDouble()
        ..date = DateTime.parse(map['date'] as String)
        ..dueDate = map['dueDate'] != null
            ? DateTime.parse(map['dueDate'] as String)
            : null
        ..notes = map['notes'] as String?
        ..imagePaths =
            List<String>.from(map['imagePaths'] as List<dynamic>? ?? [])
        ..status = map['status'] as String
        ..isDeleted = map['isDeleted'] as bool? ?? false
        ..deletedAt = map['deletedAt'] != null
            ? DateTime.parse(map['deletedAt'] as String)
            : null
        ..createdAt = DateTime.parse(map['createdAt'] as String)
        ..updatedAt = DateTime.parse(map['updatedAt'] as String)
        ..profileId = map['profileId'] as int;

  Map<String, dynamic> _repaymentToMap(Repayment repayment) => {
        'id': repayment.id,
        'friendTransactionId': repayment.friendTransactionId,
        'amount': repayment.amount,
        'date': repayment.date.toIso8601String(),
        'note': repayment.note,
        'imagePaths': repayment.imagePaths,
        'createdAt': repayment.createdAt.toIso8601String(),
      };

  Repayment _repaymentFromMap(Map<String, dynamic> map) => Repayment()
    ..id = map['id'] as int
    ..friendTransactionId = map['friendTransactionId'] as int
    ..amount = (map['amount'] as num).toDouble()
    ..date = DateTime.parse(map['date'] as String)
    ..note = map['note'] as String?
    ..imagePaths =
        List<String>.from(map['imagePaths'] as List<dynamic>? ?? [])
    ..createdAt = DateTime.parse(map['createdAt'] as String);

  Map<String, dynamic> _budgetToMap(Budget budget) => {
        'id': budget.id,
        'categoryId': budget.categoryId,
        'targetAmount': budget.targetAmount,
        'year': budget.year,
        'month': budget.month,
        'periodType': budget.periodType,
        'periodStart': budget.periodStart.toIso8601String(),
        'periodEnd': budget.periodEnd.toIso8601String(),
        'autoRepeat': budget.autoRepeat,
        'lastCycleStart': budget.lastCycleStart?.toIso8601String(),
        'warningThreshold': budget.warningThreshold,
        'warningNotified': budget.warningNotified,
        'exceededNotified': budget.exceededNotified,
        'profileId': budget.profileId,
        'createdAt': budget.createdAt.toIso8601String(),
        'updatedAt': budget.updatedAt.toIso8601String(),
      };

  Budget _budgetFromMap(Map<String, dynamic> map) {
    final year = map['year'] as int;
    final month = map['month'] as int;
    final fallbackStart = DateTime(year, month);
    final fallbackEnd = DateTime(year, month + 1)
        .subtract(const Duration(milliseconds: 1));

    return Budget()
      ..id = map['id'] as int
      ..categoryId = map['categoryId'] as int
      ..targetAmount = (map['targetAmount'] as num).toDouble()
      ..year = year
      ..month = month
      ..periodType = map['periodType'] as String? ?? 'monthly'
      ..periodStart = map['periodStart'] != null
          ? DateTime.parse(map['periodStart'] as String)
          : fallbackStart
      ..periodEnd = map['periodEnd'] != null
          ? DateTime.parse(map['periodEnd'] as String)
          : fallbackEnd
      ..autoRepeat = map['autoRepeat'] as bool? ?? true
      ..lastCycleStart = map['lastCycleStart'] != null
          ? DateTime.parse(map['lastCycleStart'] as String)
          : fallbackStart
      ..warningThreshold = (map['warningThreshold'] as num?)?.toDouble() ?? 0.8
      ..warningNotified = map['warningNotified'] as bool? ?? false
      ..exceededNotified = map['exceededNotified'] as bool? ?? false
      ..profileId = map['profileId'] as int
      ..createdAt = DateTime.parse(map['createdAt'] as String)
      ..updatedAt = DateTime.parse(map['updatedAt'] as String);
  }

  Map<String, dynamic> _recurringTemplateToMap(RecurringTemplate template) => {
        'id': template.id,
        'transactionType': template.transactionType,
        'amount': template.amount,
        'categoryId': template.categoryId,
        'source': template.source,
        'accountId': template.accountId,
        'frequency': template.frequency,
        'notes': template.notes,
        'startDate': template.startDate.toIso8601String(),
        'nextRunDate': template.nextRunDate?.toIso8601String(),
        'isActive': template.isActive,
        'isDeleted': template.isDeleted,
        'deletedAt': template.deletedAt?.toIso8601String(),
        'createdAt': template.createdAt.toIso8601String(),
        'updatedAt': template.updatedAt.toIso8601String(),
        'profileId': template.profileId,
      };

  RecurringTemplate _recurringTemplateFromMap(Map<String, dynamic> map) =>
      RecurringTemplate()
        ..id = map['id'] as int
        ..transactionType = map['transactionType'] as String
        ..amount = (map['amount'] as num).toDouble()
        ..categoryId = map['categoryId'] as int?
        ..source = map['source'] as String?
        ..accountId = map['accountId'] as int
        ..frequency = map['frequency'] as String
        ..notes = map['notes'] as String?
        ..startDate = DateTime.parse(map['startDate'] as String)
        ..nextRunDate = map['nextRunDate'] != null
            ? DateTime.parse(map['nextRunDate'] as String)
            : null
        ..isActive = map['isActive'] as bool? ?? true
        ..isDeleted = map['isDeleted'] as bool? ?? false
        ..deletedAt = map['deletedAt'] != null
            ? DateTime.parse(map['deletedAt'] as String)
            : null
        ..createdAt = DateTime.parse(map['createdAt'] as String)
        ..updatedAt = DateTime.parse(map['updatedAt'] as String)
        ..profileId = map['profileId'] as int;

  Map<String, dynamic> _reminderToMap(Reminder reminder) => {
        'id': reminder.id,
        'type': reminder.type,
        'title': reminder.title,
        'notes': reminder.notes,
        'scheduledAt': reminder.scheduledAt.toIso8601String(),
        'linkedFriendTransactionId': reminder.linkedFriendTransactionId,
        'isCompleted': reminder.isCompleted,
        'isDeleted': reminder.isDeleted,
        'deletedAt': reminder.deletedAt?.toIso8601String(),
        'createdAt': reminder.createdAt.toIso8601String(),
        'updatedAt': reminder.updatedAt.toIso8601String(),
        'profileId': reminder.profileId,
      };

  Reminder _reminderFromMap(Map<String, dynamic> map) => Reminder()
    ..id = map['id'] as int
    ..type = map['type'] as String
    ..title = map['title'] as String
    ..notes = map['notes'] as String?
    ..scheduledAt = DateTime.parse(map['scheduledAt'] as String)
    ..linkedFriendTransactionId = map['linkedFriendTransactionId'] as int?
    ..isCompleted = map['isCompleted'] as bool? ?? false
    ..isDeleted = map['isDeleted'] as bool? ?? false
    ..deletedAt = map['deletedAt'] != null
        ? DateTime.parse(map['deletedAt'] as String)
        : null
    ..createdAt = DateTime.parse(map['createdAt'] as String)
    ..updatedAt = DateTime.parse(map['updatedAt'] as String)
    ..profileId = map['profileId'] as int;
}
