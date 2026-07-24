import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mamabloom/screens/hospital_bag_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HospitalBagScreen loads without error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HospitalBagScreen()),
    );
    await tester.pump(); // start load
    await tester.pumpAndSettle();

    expect(find.text('Hospital Bag'), findsOneWidget);
    expect(find.textContaining('packed'), findsWidgets);
  });
}
