import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kistas/main.dart';
import 'package:kistas/core/data/database_service.dart';
import 'package:kistas/core/repositories/app_repository.dart';

class _FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.createTempSync('kistas_test').path;
  }

  @override
  Future<String?> getTemporaryPath() async {
    return Directory.systemTemp.createTempSync('kistas_test_tmp').path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();

  testWidgets('Uygulama ana ekranı açılıyor', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = DatabaseService();
    await db.init();
    final repository = await AppRepository.init(db);
    await tester.pumpWidget(KistasApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.textContaining('Merhaba'), findsOneWidget);
  });
}
