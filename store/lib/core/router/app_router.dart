import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/artisan/presentation/screens/artisan_dashboard_screen.dart';
import '../../../build/lib/features/artisan/presentation/screens/artisan_profile_screen.dart';
import '../../../build/lib/features/products/presentation/screens/product_management_screen.dart';
import '../../../build/lib/features/products/presentation/screens/add_edit_product_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';
import '../../../build/lib/features/orders/presentation/screens/artisan_orders_screen.dart';
import '../../../build/lib/features/orders/presentation/screens/order_detail_screen.dart';
import '../../../build/lib/features/customer/presentation/screens/customer_home_screen.dart';
import '../../../build/lib/features/customer/presentation/screens/artisan_storefront_screen.dart';
import '../../../build/lib/features/customer/presentation/screens/customer_cart_screen.dart';
import '../../../build/lib/features/customer/presentation/screens/customer_orders_screen.dart';
import '../../../build/lib/features/customer/presentation/screens/customer_profile_screen.dart';
import '../../../build/lib/features/customer/presentation/screens/browse_products_screen.dart';

/// Route path constants for type-safe navigation
class AppRoutes {
  AppRoutes._();
  
  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String roleSelection = '/role-selection';
  
  // Artisan Routes
  static const String artisanDashboard = '/artisan/dashboard';
  static const String artisanProducts = '/artisan/products';
  static const String artisanAddProduct = '/artisan/products/add';
  static const String artisanEditProduct = '/artisan/products/edit/:productId';
  static const String artisanOrders = '/artisan/orders';
  static const String artisanOrderDetail = '/artisan/orders/:orderId';
  static const String artisanProfile = '/artisan/profile';
  
  // Customer Routes
  static const String customerHome = '/customer/home';
  static const String customerBrowse = '/customer/browse';
  static const String customerStorefront = '/customer/storefront/:artisanId';
  static const String customerProductDetail = '/customer/product/:productId';
  static const String customerCart = '/customer/cart';
  static const String customerOrders = '/customer/orders';
  static const String customerOrderDetail = '/customer/orders/:orderId';
  static const String customerProfile = '/customer/profile';
}

/// Provider for the app router with authentication-based redirects
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    
    // Redirect logic based on authentication state
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final userRole = ref.read(currentUserProvider)?.role;
      final currentPath = state.matchedLocation;
      
      // Allow splash screen to handle initial navigation
      if (currentPath == AppRoutes.splash) {
        return null;
      }
      
      // If not logged in, redirect to login (except for auth routes)
      final isAuthRoute = currentPath == AppRoutes.login || 
                         currentPath == AppRoutes.register ||
                         currentPath == AppRoutes.roleSelection;
      
      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }
      
      // If logged in and trying to access auth routes, redirect to appropriate dashboard
      if (isLoggedIn && isAuthRoute) {
        if (userRole == 'artisan') {
          return AppRoutes.artisanDashboard;
        } else if (userRole == 'customer') {
          return AppRoutes.customerHome;
        }
      }
      
      return null;
    },
    
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      
      // Artisan Routes
      GoRoute(
        path: AppRoutes.artisanDashboard,
        builder: (context, state) => const ArtisanDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.artisanProducts,
        builder: (context, state) => const ProductManagementScreen(),
      ),
      GoRoute(
        path: AppRoutes.artisanAddProduct,
        builder: (context, state) => const AddEditProductScreen(),
      ),
      GoRoute(
        path: AppRoutes.artisanEditProduct,
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return AddEditProductScreen(productId: productId);
        },
      ),
      GoRoute(
        path: AppRoutes.artisanOrders,
        builder: (context, state) => const ArtisanOrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.artisanOrderDetail,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderDetailScreen(orderId: orderId, isArtisan: true);
        },
      ),
      GoRoute(
        path: AppRoutes.artisanProfile,
        builder: (context, state) => const ArtisanProfileScreen(),
      ),
      
      // Customer Routes
      GoRoute(
        path: AppRoutes.customerHome,
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerBrowse,
        builder: (context, state) => const BrowseProductsScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerStorefront,
        builder: (context, state) {
          final artisanId = state.pathParameters['artisanId']!;
          return ArtisanStorefrontScreen(artisanId: artisanId);
        },
      ),
      GoRoute(
        path: AppRoutes.customerProductDetail,
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: AppRoutes.customerCart,
        builder: (context, state) => const CustomerCartScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerOrders,
        builder: (context, state) => const CustomerOrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerOrderDetail,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderDetailScreen(orderId: orderId, isArtisan: false);
        },
      ),
      GoRoute(
        path: AppRoutes.customerProfile,
        builder: (context, state) => const CustomerProfileScreen(),
      ),
    ],
    
    // Error page for unknown routes
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.matchedLocation),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
