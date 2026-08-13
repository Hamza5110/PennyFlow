import 'package:flutter_test/flutter_test.dart';
import 'package:spend_vault/core/constants/reminder_constants.dart';

void main() {
  group('ReminderTypes', () {
    test('includes all SRS reminder types', () {
      expect(ReminderTypes.all, contains(ReminderTypes.billDue));
      expect(ReminderTypes.all, contains(ReminderTypes.friendPaymentDue));
      expect(ReminderTypes.all, contains(ReminderTypes.subscriptionRenewal));
      expect(ReminderTypes.all, contains(ReminderTypes.insurance));
      expect(ReminderTypes.all, contains(ReminderTypes.custom));
    });

    test('manual types exclude friend payment due', () {
      expect(ReminderTypes.manualTypes, isNot(contains(ReminderTypes.friendPaymentDue)));
      expect(ReminderTypes.manualTypes.length, 4);
    });
  });
}
