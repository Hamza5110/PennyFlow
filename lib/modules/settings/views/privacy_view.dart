import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_scaffold.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'settings_privacy'.tr,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'settings_privacy_title'.tr,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'settings_privacy_body'.tr,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
