import 'package:isar_community/isar.dart';

import '../../models/app_meta.dart';
import '../../models/budget.dart';
import '../../models/budget_envelope.dart';
import '../../models/category.dart';
import '../../models/expense.dart';
import '../../models/friend.dart';
import '../../models/friend_transaction.dart';
import '../../models/income.dart';
import '../../models/payment_account.dart';
import '../../models/profile.dart';
import '../../models/recurring_template.dart';
import '../../models/reminder.dart';
import '../../models/repayment.dart';

abstract final class IsarSchemas {
  static List<CollectionSchema<dynamic>> get all => [
        AppMetaSchema,
        ProfileSchema,
        CategorySchema,
        PaymentAccountSchema,
        ExpenseSchema,
        IncomeSchema,
        FriendSchema,
        FriendTransactionSchema,
        RepaymentSchema,
        BudgetSchema,
        BudgetEnvelopeSchema,
        RecurringTemplateSchema,
        ReminderSchema,
      ];
}
