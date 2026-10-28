import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../providers/catalog_providers.dart';
import '../widgets/floating_cart_pill.dart';
import 'auth_pages.dart';
import 'cart_page.dart';
import 'categories_page.dart';
import 'category_page.dart';
import 'home_demo_page.dart';
import 'landing_page.dart';
import 'placeholder_pages.dart';
import 'product_page.dart';

/// Top-level shell widget with a Material 3 NavigationBar for the 4 destinations
/// (Home, Categories, Orders, Profile). The cart is NOT a tab: a floating "View cart" pill
/// hovers above the bottom navigation while the cart is not empty.
class AppShellScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShellScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(uiV2LanguageProvider);
    final strings = AppStrings.of(language);
    final s = (MediaQuery.sizeOf(context).width / 360.0).clamp(0.85, 1.25);

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          // The body ends above the bottom navigation, so the pill hovers just above it.
          Positioned(
            left: 0,
            right: 0,
            bottom: 12.0 * s,
            child: const Center(child: FloatingCartPill()),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: strings.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.category_outlined),
            selectedIcon: const Icon(Icons.category),
            label: strings.navCategories,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: strings.navOrders,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: strings.navProfile,
          ),
        ],
      ),
    );
  }
}

/// In-memory tracker for whether the 3-slide landing sequence has been seen.
/// (In-memory for this demo; persistent storage will be integrated later).
final ValueNotifier<bool> uiV2LandingSeen = ValueNotifier<bool>(false);

/// GoRouter configuration for the VanMitra guest-browseable shell, the intro landing flow and the
/// full-screen pages (cart, product, sign in, create account).
final uiV2Router = GoRouter(
  initialLocation: '/',
  refreshListenable: uiV2LandingSeen,
  redirect: (context, state) {
    final bool seen = uiV2LandingSeen.value;
    final bool isAtLanding = state.matchedLocation == '/landing';
    if (!seen && !isAtLanding) {
      return '/landing';
    }
    if (seen && isAtLanding) {
      return '/';
    }
    return null;
  },
  routes: [
    // Landing Route (outside the tabbed shell)
    GoRoute(
      path: '/landing',
      builder: (context, state) => const LandingPage(),
    ),

    // Full-screen pages (outside the tabbed shell, each with its own back arrow)
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: '/product/:code',
      builder: (context, state) => ProductPage(productCode: state.pathParameters['code'] ?? ''),
    ),
    GoRoute(
      path: '/signin',
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpPage(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShellScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Destination 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeDemoPage(),
            ),
          ],
        ),

        // Destination 1: Categories
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/categories',
              builder: (context, state) => const CategoriesPage(),
              routes: [
                // A category page stays inside the shell, so the bottom bar and the cart pill remain
                GoRoute(
                  path: ':slug',
                  builder: (context, state) => CategoryPage(slug: state.pathParameters['slug'] ?? 'all'),
                ),
              ],
            ),
          ],
        ),

        // Destination 2: Orders
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrdersPlaceholderPage(),
            ),
          ],
        ),

        // Destination 3: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePlaceholderPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
