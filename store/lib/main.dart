import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

/// Entry point of the Artisan Marketplace application.
/// 
/// This app enables local artisans to create digital storefronts
/// and customers to browse and purchase handmade products.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    // ProviderScope wraps the entire app for Riverpod state management
    const ProviderScope(
      child: ArtisanMarketplaceApp(),
    ),
  );
}

/// Root widget of the application.
/// 
/// Uses GoRouter for declarative routing and Material 3 theming.
class ArtisanMarketplaceApp extends ConsumerWidget {
  const ArtisanMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'Artisan Marketplace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
