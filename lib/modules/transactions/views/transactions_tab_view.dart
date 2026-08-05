import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../expenses/views/expenses_list_view.dart';
import '../../income/views/incomes_list_view.dart';

class TransactionsTabView extends StatelessWidget {
  const TransactionsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              tabs: [
                Tab(text: 'transactions_expenses_tab'.tr),
                Tab(text: 'transactions_income_tab'.tr),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                ExpensesListView(),
                IncomesListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
