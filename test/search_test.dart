import 'package:flutter_test/flutter_test.dart';
import 'package:penny_flow/core/utils/search_match_utils.dart';
import 'package:penny_flow/data/models/search/global_search_filter.dart';

void main() {
  group('SearchMatchUtils', () {
    test('matches amount and notes', () {
      expect(
        SearchMatchUtils.matches('lunch', ['Lunch', '25.50']),
        isTrue,
      );
      expect(
        SearchMatchUtils.matches('travel', ['Lunch', '25.50']),
        isFalse,
      );
    });

    test('matches formatted date tokens', () {
      final date = DateTime(2026, 3, 15);
      expect(
        SearchMatchUtils.matches('2026', const [], date: date),
        isTrue,
      );
      expect(
        SearchMatchUtils.matches('15/3/2026', const [], date: date),
        isTrue,
      );
    });
  });

  group('GlobalSearchFilter', () {
    test('detects active filters', () {
      expect(GlobalSearchFilter.empty.hasActiveFilters, isFalse);
      expect(
        const GlobalSearchFilter(searchQuery: 'fuel').hasActiveFilters,
        isTrue,
      );
      expect(
        const GlobalSearchFilter(scope: GlobalSearchScope.expenses)
            .hasActiveFilters,
        isTrue,
      );
    });

    test('copyWith clears optional fields', () {
      const initial = GlobalSearchFilter(
        categoryId: 1,
        accountId: 2,
        friendId: 3,
        friendStatus: 'pending',
        tag: 'work',
      );
      final cleared = initial.copyWith(
        clearCategory: true,
        clearAccount: true,
        clearFriend: true,
        clearStatus: true,
        clearTag: true,
      );
      expect(cleared.categoryId, isNull);
      expect(cleared.accountId, isNull);
      expect(cleared.friendId, isNull);
      expect(cleared.friendStatus, isNull);
      expect(cleared.tag, isNull);
    });
  });
}
