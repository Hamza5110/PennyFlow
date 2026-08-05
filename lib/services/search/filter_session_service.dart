import 'package:get/get.dart';

import '../../data/models/expense/expense_filter.dart';
import '../../data/models/friend/friend_models.dart';
import '../../data/models/income/income_filter.dart';
import '../../data/models/search/global_search_filter.dart';

/// In-memory filter persistence for the current app session (FR-107).
class FilterSessionService extends GetxService {
  ExpenseFilter expenseFilter = ExpenseFilter.empty;
  IncomeFilter incomeFilter = IncomeFilter.empty;
  FriendFilter friendFilter = FriendFilter.empty;
  GlobalSearchFilter globalSearchFilter = GlobalSearchFilter.empty;
}
