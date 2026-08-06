import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_scaffold.dart';

/// Open-source dependency licenses (Flutter [LicensePage]).
class LicensesView extends StatefulWidget {
  const LicensesView({super.key});

  @override
  State<LicensesView> createState() => _LicensesViewState();
}

class _LicensesViewState extends State<LicensesView> {
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'settings_licenses'.tr,
      body: FutureBuilder<PackageInfo>(
        future: _packageInfo,
        builder: (context, snapshot) {
          final info = snapshot.data;
          return LicensePage(
            applicationName: AppConstants.appName,
            applicationVersion: info == null
                ? ''
                : '${info.version} (${info.buildNumber})',
            applicationLegalese: 'settings_licenses_legalese'.tr,
          );
        },
      ),
    );
  }
}
