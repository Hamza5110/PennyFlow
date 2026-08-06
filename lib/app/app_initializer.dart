import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../core/errors/error_handler.dart';
import '../core/logging/app_logger.dart';
import '../data/local/database/isar_database.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/friend_repository.dart';
import '../data/repositories/friend_transaction_repository.dart';
import '../data/repositories/income_repository.dart';
import '../data/repositories/payment_account_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/repayment_repository.dart';
import '../data/repositories/recurring_template_repository.dart';
import '../data/repositories/reminder_repository.dart';
import '../services/auth/auth_service.dart';
import '../services/budget/budget_service.dart';
import '../services/category/category_service.dart';
import '../services/dashboard/dashboard_service.dart';
import '../services/expense/expense_service.dart';
import '../services/friend/friend_service.dart';
import '../services/image/image_service.dart';
import '../services/income/income_service.dart';
import '../services/notification/notification_service.dart';
import '../services/payment_account/payment_account_service.dart';
import '../services/backup/backup_bundle_builder.dart';
import '../services/backup/backup_bundle_restorer.dart';
import '../services/backup/backup_service.dart';
import '../services/backup/backup_snapshot_codec.dart';
import '../services/backup/google_drive_backup_client.dart';
import '../services/auth/auth_session_store.dart';
import '../services/auth/google_sign_in_client.dart';
import '../services/lifecycle/app_lifecycle_service.dart';
import '../services/profile/profile_service.dart';
import '../services/recurring/recurring_service.dart';
import '../services/reminder/reminder_service.dart';
import '../services/cache/profile_lookup_cache_service.dart';
import '../services/security/app_lock_service.dart';
import '../services/search/filter_session_service.dart';
import '../services/search/search_service.dart';
import '../services/settings/settings_service.dart';
import '../services/startup/startup_service.dart';
import '../services/storage/local_storage_service.dart';
import '../services/storage/secure_storage_service.dart';
import '../data/repositories/update_repository.dart';
import '../services/update/apk_download_manager.dart';
import '../services/update/github_release_client.dart';
import '../services/update/update_service.dart';
import 'config/env_config.dart';

/// Ordered cold-start bootstrap before [runApp].
abstract final class AppInitializer {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    EnvConfig.init();
    AppLogger.instance.configure(isDebug: EnvConfig.current.enableLogging);
    AppLogger.instance.i(
      'Bootstrapping PennyFlow (${EnvConfig.current.environment.name})',
    );

    ErrorHandler.installGlobalHandlers();

    final localStorage = await Get.putAsync<LocalStorageService>(
      () async => LocalStorageService().init(),
      permanent: true,
    );

    await Get.putAsync<SecureStorageService>(
      () async => SecureStorageService().init(),
      permanent: true,
    );

    Get.put<GoogleSignInClient>(GoogleSignInClient(), permanent: true);

    await Get.putAsync<IsarDatabase>(
      () async => IsarDatabase().init(),
      permanent: true,
    );

    final settings = await Get.putAsync<SettingsService>(
      () async => SettingsService(localStorage).init(),
      permanent: true,
    );

    final isar = Get.find<IsarDatabase>();

    Get.put<ProfileRepository>(
      ProfileRepository(isar),
      permanent: true,
    );

    Get.put<CategoryRepository>(CategoryRepository(isar), permanent: true);
    Get.put<PaymentAccountRepository>(
      PaymentAccountRepository(isar),
      permanent: true,
    );
    Get.put<ExpenseRepository>(ExpenseRepository(isar), permanent: true);
    Get.put<IncomeRepository>(IncomeRepository(isar), permanent: true);
    Get.put<FriendRepository>(FriendRepository(isar), permanent: true);
    Get.put<FriendTransactionRepository>(
      FriendTransactionRepository(isar),
      permanent: true,
    );
    Get.put<RepaymentRepository>(RepaymentRepository(isar), permanent: true);
    Get.put<BudgetRepository>(BudgetRepository(isar), permanent: true);
    Get.put<RecurringTemplateRepository>(
      RecurringTemplateRepository(isar),
      permanent: true,
    );
    Get.put<ReminderRepository>(
      ReminderRepository(isar),
      permanent: true,
    );
    Get.put<ImageService>(ImageService(), permanent: true);
    Get.put<FilterSessionService>(FilterSessionService(), permanent: true);

    await Get.putAsync<CategoryService>(
      () async => CategoryService(
        Get.find<CategoryRepository>(),
        Get.find<ExpenseRepository>(),
        settings,
      ).init(),
      permanent: true,
    );

    await Get.putAsync<PaymentAccountService>(
      () async => PaymentAccountService(
        Get.find<PaymentAccountRepository>(),
        Get.find<ExpenseRepository>(),
        Get.find<IncomeRepository>(),
        settings,
      ).init(),
      permanent: true,
    );

    await Get.putAsync<NotificationService>(
      () async => NotificationService().init(),
      permanent: true,
    );

    Get.put<BudgetService>(
      BudgetService(
        Get.find<BudgetRepository>(),
        Get.find<ExpenseRepository>(),
        Get.find<CategoryRepository>(),
        Get.find<NotificationService>(),
        settings,
      ),
      permanent: true,
    );

    Get.put<ExpenseService>(
      ExpenseService(
        Get.find<ExpenseRepository>(),
        Get.find<CategoryService>(),
        Get.find<PaymentAccountService>(),
        Get.find<ImageService>(),
        settings,
      ),
      permanent: true,
    );

    Get.put<IncomeService>(
      IncomeService(
        Get.find<IncomeRepository>(),
        Get.find<PaymentAccountService>(),
        Get.find<ImageService>(),
        settings,
      ),
      permanent: true,
    );

    Get.put<RecurringService>(
      RecurringService(
        Get.find<RecurringTemplateRepository>(),
        Get.find<ExpenseService>(),
        Get.find<IncomeService>(),
        Get.find<ExpenseRepository>(),
        Get.find<IncomeRepository>(),
        Get.find<CategoryRepository>(),
        Get.find<PaymentAccountRepository>(),
        Get.find<NotificationService>(),
        settings,
      ),
      permanent: true,
    );

    Get.put<ReminderService>(
      ReminderService(
        Get.find<ReminderRepository>(),
        Get.find<FriendRepository>(),
        Get.find<NotificationService>(),
        settings,
      ),
      permanent: true,
    );

    Get.put<FriendService>(
      FriendService(
        Get.find<FriendRepository>(),
        Get.find<FriendTransactionRepository>(),
        Get.find<RepaymentRepository>(),
        Get.find<ImageService>(),
        settings,
      ),
      permanent: true,
    );

    Get.put<SearchService>(
      SearchService(
        Get.find<ExpenseService>(),
        Get.find<IncomeService>(),
        Get.find<FriendService>(),
        settings,
      ),
      permanent: true,
    );

    Get.put<DashboardRepository>(
      DashboardRepository(
        Get.find<ExpenseRepository>(),
        Get.find<IncomeRepository>(),
        Get.find<CategoryRepository>(),
        Get.find<PaymentAccountRepository>(),
        Get.find<FriendService>(),
        Get.find<BudgetService>(),
      ),
      permanent: true,
    );

    Get.put<DashboardService>(
      DashboardService(
        Get.find<DashboardRepository>(),
        settings,
      ),
      permanent: true,
    );

    await Get.putAsync<ProfileService>(
      () async => ProfileService(
        Get.find<ProfileRepository>(),
        settings,
        Get.find<CategoryService>(),
        Get.find<PaymentAccountService>(),
      ).init(),
      permanent: true,
    );

    await Get.putAsync<AuthService>(
      () async => AuthService(
        Get.find<GoogleSignInClient>(),
        AuthSessionStore(Get.find<SecureStorageService>()),
        Get.find<ProfileService>(),
        settings,
      ).init(),
      permanent: true,
    );

    Get.put<GoogleDriveBackupClient>(
      GoogleDriveBackupClient(Get.find<GoogleSignInClient>()),
      permanent: true,
    );
    Get.put<BackupSnapshotCodec>(
      BackupSnapshotCodec(isar),
      permanent: true,
    );
    Get.put<BackupBundleBuilder>(
      BackupBundleBuilder(
        Get.find<BackupSnapshotCodec>(),
        settings,
        localStorage,
      ),
      permanent: true,
    );
    Get.put<BackupBundleRestorer>(
        BackupBundleRestorer(
          Get.find<BackupSnapshotCodec>(),
          settings,
          localStorage,
          Get.find<ImageService>(),
        ),
      permanent: true,
    );
    Get.put<BackupService>(
      BackupService(
        Get.find<AuthService>(),
        settings,
        Get.find<ReminderService>(),
        Get.find<GoogleDriveBackupClient>(),
        Get.find<BackupBundleBuilder>(),
        Get.find<BackupBundleRestorer>(),
        Get.find<BackupSnapshotCodec>(),
      ),
      permanent: true,
    );

    Get.put<UpdateRepository>(UpdateRepository(localStorage), permanent: true);
    Get.put<GitHubReleaseClient>(GitHubReleaseClient(), permanent: true);
    Get.put<ApkDownloadManager>(ApkDownloadManager(), permanent: true);
    await Get.putAsync<UpdateService>(
      () async => UpdateService(
        settings,
        Get.find<GitHubReleaseClient>(),
        Get.find<ApkDownloadManager>(),
        Get.find<UpdateRepository>(),
      ).init(),
      permanent: true,
    );

    Get.put<AppLockService>(
      AppLockService(
        settings,
        Get.find<SecureStorageService>(),
        Get.find<ProfileRepository>(),
      ),
      permanent: true,
    );

    Get.put<ProfileLookupCacheService>(
      ProfileLookupCacheService(settings),
      permanent: true,
    );

    await Get.putAsync<StartupService>(
      () async => StartupService(
        settings,
        Get.find<ProfileService>(),
      ),
      permanent: true,
    );

    await Get.putAsync<AppLifecycleService>(
      () async => AppLifecycleService(
        settings,
        localStorage,
        Get.find<StartupService>(),
        Get.find<RecurringService>(),
        Get.find<ReminderService>(),
        Get.find<BackupService>(),
      ).init(),
      permanent: true,
    );

    if (settings.activeProfileId != null) {
      await Get.find<RecurringService>().processDueTemplates();
      await Get.find<ReminderService>().rescheduleAll();
    }

    if (kDebugMode) {
      AppLogger.instance.d('AppInitializer complete');
    }
  }
}
