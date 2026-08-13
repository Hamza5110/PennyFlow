/// Controls how much of the app's surface area is exposed to the user.
///
/// [simple] trims bottom navigation to the essentials and speeds up
/// transaction entry; [full] keeps every tab and field visible, as before.
enum AppMode {
  simple,
  full;

  String get labelKey => switch (this) {
        AppMode.simple => 'app_mode_simple',
        AppMode.full => 'app_mode_full',
      };

  String get descriptionKey => switch (this) {
        AppMode.simple => 'app_mode_simple_description',
        AppMode.full => 'app_mode_full_description',
      };

  static AppMode fromStorage(String? raw) {
    return AppMode.values.firstWhere(
      (v) => v.name == raw,
      orElse: () => AppMode.simple,
    );
  }
}
