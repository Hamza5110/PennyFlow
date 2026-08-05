import '../constants/app_constants.dart';

/// Shared validation limits referenced by forms and services.
///
/// Feature modules should use these instead of hard-coding numbers.
abstract final class ValidationConstants {
  static const double minAmount = 0.01;
  static const double maxAmount = AppConstants.maxAmount;
  static const int amountDecimalPlaces = 2;

  static const int minNameLength = 1;
  static const int maxCategoryNameLength = AppConstants.maxNameLength;
  static const int maxAccountNameLength = AppConstants.maxNameLength;
  static const int maxFriendNameLength = AppConstants.maxFriendNameLength;
  static const int maxNotesLength = AppConstants.maxNotesLength;
  static const int maxTagLength = AppConstants.maxTagLength;
  static const int maxTags = AppConstants.maxTagsPerTransaction;

  static const int minPinLength = 4;
  static const int maxPinLength = 6;
}
