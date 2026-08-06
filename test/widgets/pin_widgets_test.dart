import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penny_flow/core/widgets/pin_dots.dart';
import 'package:penny_flow/core/widgets/pin_pad.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PinDots', () {
    testWidgets('renders filled and empty indicators', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PinDots(length: 2, maxLength: 4),
          ),
        ),
      );

      expect(find.byType(PinDots), findsOneWidget);
      expect(find.byType(AnimatedContainer), findsNWidgets(4));
    });

    testWidgets('uses error color when hasError is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
          home: const Scaffold(
            body: PinDots(length: 1, maxLength: 4, hasError: true),
          ),
        ),
      );

      final theme = Theme.of(tester.element(find.byType(PinDots)));
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.border?.top.color, theme.colorScheme.error);
    });
  });

  group('PinPad', () {
    testWidgets('invokes onDigit and onBackspace', (tester) async {
      final digits = <String>[];
      var backspaces = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PinPad(
              onDigit: digits.add,
              onBackspace: () => backspaces++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('1'));
      await tester.tap(find.text('0'));
      await tester.tap(find.byIcon(Icons.backspace_outlined));

      expect(digits, ['1', '0']);
      expect(backspaces, 1);
    });

    testWidgets('shows biometric button when enabled', (tester) async {
      var biometricTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PinPad(
              onDigit: (_) {},
              onBackspace: () {},
              showBiometric: true,
              onBiometric: () => biometricTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.fingerprint_rounded));
      expect(biometricTapped, isTrue);
    });
  });
}
