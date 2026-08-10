import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/products/presentation/product_detail_screen.dart';
import 'features/products/presentation/product_list_screen.dart';
import 'widgets/error_state.dart';
import 'widgets/loading_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const FakeStoreApp(),
    ),
  );
}

class FakeStoreApp extends ConsumerWidget {
  const FakeStoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Store Front',
      theme: AppTheme.lightTheme,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/products': (context) => const ProductListScreen(),
        '/product-detail': (context) => const ProductDetailScreen(),
      },
      home: authState.when(
        data: (state) {
          if (state.isAuthenticated) {
            return const ProductListScreen();
          } else {
            return const LoginScreen();
          }
        },
        loading: () => const Scaffold(
          body: LoadingIndicator(message: 'Initializing session...'),
        ),
        error: (error, _) => Scaffold(
          body: ErrorState(
            message: 'Failed to initialize application session.',
            onRetry: () => ref.refresh(authProvider),
          ),
        ),
      ),
    );
  }
}
