import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rssb_store_app/providers/inventory_provider.dart';
import 'package:rssb_store_app/screens/home_screen.dart';

void main() {
  testWidgets('App renders HomeScreen correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    final provider = InventoryProvider(autoSync: false);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Initial pump shows CircularProgressIndicator or HomeScreen
    await tester.pump();
    // Allow async _init() microtasks to resolve
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
