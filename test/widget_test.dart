import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fake_store_app/main.dart';
import 'package:fake_store_app/features/auth/data/auth_repository.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  testWidgets('app builds successfully', (WidgetTester tester) async {
    final mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
        child: const FakeStoreApp(),
      ),
    );
    expect(find.byType(FakeStoreApp), findsOneWidget);
  });
}

