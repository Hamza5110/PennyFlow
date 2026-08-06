import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/update_controller.dart';

class UpdateHistoryView extends GetView<UpdateController> {
  const UpdateHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'update_history_title'.tr,
      body: Obx(() {
        final history = controller.history;
        if (history.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'update_history_empty'.tr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          separatorBuilder: (_, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final entry = history[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.system_update_alt_rounded),
                title: Text('v${entry.version}'),
                subtitle: Text(
                  '${AppFormatters.dateTime(entry.installedAt)}\n'
                  '${controller.historyStatusLabel(entry.status)}',
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      }),
    );
  }
}
