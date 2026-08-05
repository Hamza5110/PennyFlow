import 'package:flutter/material.dart';

/// Category icon and color helpers for lists, forms, and pickers.
abstract final class CategoryIcons {
  static const List<String> availableKeys = [
    'restaurant',
    'local_gas_station',
    'shopping_bag',
    'home',
    'receipt_long',
    'movie',
    'shopping_cart',
    'medical_services',
    'school',
    'trending_up',
    'family_restroom',
    'more_horiz',
    'directions_car',
    'flight',
    'fitness_center',
    'pets',
    'child_care',
    'work',
    'phone',
    'wifi',
    'coffee',
    'local_cafe',
    'sports_esports',
    'music_note',
    'book',
    'build',
    'lightbulb',
    'favorite',
    'card_giftcard',
    'savings',
    'account_balance',
  ];

  static const List<String> colorPalette = [
    '#F97316',
    '#EAB308',
    '#EC4899',
    '#8B5CF6',
    '#3B82F6',
    '#A855F7',
    '#22C55E',
    '#EF4444',
    '#0EA5E9',
    '#14B8A6',
    '#F43F5E',
    '#64748B',
    '#059669',
    '#D97706',
    '#7C3AED',
    '#2563EB',
  ];

  static IconData fromKey(String key) {
    switch (key) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'local_gas_station':
        return Icons.local_gas_station_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'receipt_long':
        return Icons.receipt_long_rounded;
      case 'movie':
        return Icons.movie_rounded;
      case 'shopping_cart':
        return Icons.shopping_cart_rounded;
      case 'medical_services':
        return Icons.medical_services_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'family_restroom':
        return Icons.family_restroom_rounded;
      case 'directions_car':
        return Icons.directions_car_rounded;
      case 'flight':
        return Icons.flight_rounded;
      case 'fitness_center':
        return Icons.fitness_center_rounded;
      case 'pets':
        return Icons.pets_rounded;
      case 'child_care':
        return Icons.child_care_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'phone':
        return Icons.phone_rounded;
      case 'wifi':
        return Icons.wifi_rounded;
      case 'coffee':
        return Icons.coffee_rounded;
      case 'local_cafe':
        return Icons.local_cafe_rounded;
      case 'sports_esports':
        return Icons.sports_esports_rounded;
      case 'music_note':
        return Icons.music_note_rounded;
      case 'book':
        return Icons.book_rounded;
      case 'build':
        return Icons.build_rounded;
      case 'lightbulb':
        return Icons.lightbulb_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      case 'card_giftcard':
        return Icons.card_giftcard_rounded;
      case 'savings':
        return Icons.savings_rounded;
      case 'account_balance':
        return Icons.account_balance_rounded;
      case 'more_horiz':
        return Icons.more_horiz_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  static Color parseColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
