import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';

import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/search_controller.dart';
import '../widgets/global_search_filter_sheet.dart';
import '../widgets/global_search_result_tile.dart';

class SearchView extends GetView<SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = Get.find<SettingsService>().currencyCode.value;

    return AppScaffold(
      title: 'search_title'.tr,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    controller: controller.searchFieldController,
                    decoration: InputDecoration(
                      hintText: 'search_hint'.tr,
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                    onChanged: controller.onSearchChanged,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list_rounded),
                  onPressed: () => GlobalSearchFilterSheet.show(
                    initial: controller.filter.value,
                    onApply: controller.applyFilter,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.filter.value.hasActiveFilters) {
              return Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: controller.clearFilters,
                  child: Text('expense_clear_filters'.tr),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.results.isEmpty) {
                return AppLoadingIndicator(message: 'common_loading'.tr);
              }
              if (controller.searchText.value.trim().isEmpty &&
                  !controller.filter.value.hasActiveFilters) {
                return AppEmptyState(
                  title: 'search_empty_prompt_title'.tr,
                  message: 'search_empty_prompt_message'.tr,
                  icon: Icons.search_rounded,
                );
              }
              if (controller.results.isEmpty) {
                return AppEmptyState(
                  title: 'search_no_results'.tr,
                  message: 'search_no_results_message'.tr,
                  icon: Icons.search_off_rounded,
                );
              }
              return ListView.separated(
                itemCount: controller.results.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = controller.results[index];
                  return GlobalSearchResultTile(
                    item: item,
                    currencyCode: currency,
                    onTap: () => controller.openResult(item),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
