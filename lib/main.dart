import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/inventory_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try initializing Firebase safely with fallback handling
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init fallback: App running in offline local-sync mode. Error: $e');
  }

  runApp(const RSSBStoreApp());
}

class RSSBStoreApp extends StatelessWidget {
  const RSSBStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoryProvider(),
      child: MaterialApp(
        title: 'RSSB Store App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
