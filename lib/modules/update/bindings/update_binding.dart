import 'package:get/get.dart';

import '../../../data/repositories/update_repository.dart';
import '../../../services/settings/settings_service.dart';
import '../../../services/storage/local_storage_service.dart';
import '../../../services/update/apk_download_manager.dart';
import '../../../services/update/github_release_client.dart';
import '../../../services/update/update_service.dart';
import '../controllers/update_controller.dart';

class UpdateBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UpdateRepository>()) {
      Get.put(
        UpdateRepository(Get.find<LocalStorageService>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<GitHubReleaseClient>()) {
      Get.put(GitHubReleaseClient(), permanent: true);
    }

    if (!Get.isRegistered<ApkDownloadManager>()) {
      Get.put(ApkDownloadManager(), permanent: true);
    }

    if (!Get.isRegistered<UpdateService>()) {
      Get.putAsync<UpdateService>(
        () async => UpdateService(
          Get.find<SettingsService>(),
          Get.find<GitHubReleaseClient>(),
          Get.find<ApkDownloadManager>(),
          Get.find<UpdateRepository>(),
        ).init(),
        permanent: true,
      );
    }

    Get.lazyPut<UpdateController>(
      () => UpdateController(Get.find<UpdateService>()),
    );
  }
}
