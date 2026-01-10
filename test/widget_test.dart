// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kistas/main.dart';
import 'package:kistas/core/repositories/app_repository.dart';

void main() {
  testWidgets('Uygulama ana ekranı açılıyor', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = await AppRepository.init();
    await tester.pumpWidget(KistasApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.textContaining('Merhaba'), findsOneWidget);
  });
}
