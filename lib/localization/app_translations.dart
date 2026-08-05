import 'package:get/get.dart';

import 'locales/en_us.dart';
import 'locales/ur_pk.dart';

/// GetX translations registry.
///
/// Usage: `'common_save'.tr`
/// Add locales by extending [keys]. Feature modules should only add keys —
/// never hard-code user-facing strings in widgets when a key exists.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUs,
        'en': enUs,
        'ur_PK': urPk,
        'ur': urPk,
      };
}
