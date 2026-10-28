import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../providers/catalog_providers.dart';
import 'home_demo_page.dart';
import 'landing_page.dart';
import 'placeholder_pages.dart';

/// Top-level shell widget with Material 3 NavigationBar for the 5 guest-accessible destinations.
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
    final cartItemCount = ref.watch(cartItemCountProvider);

    final Widget cartIcon = cartItemCount > 0
        ? Badge.count(
            count: cartItemCount,
            child: const Icon(Icons.shopping_cart_outlined),
          )
        : const Icon(Icons.shopping_cart_outlined);

    final Widget cartSelectedIcon = cartItemCount > 0
        ? Badge.count(
            count: cartItemCount,
            child: const Icon(Icons.shopping_cart),
          )
        : const Icon(Icons.shopping_cart);

    final String cartLabel = cartItemCount > 0
        ? strings.cartSemantic(cartItemCount)
        : strings.navCart;

    return Scaffold(
      body: navigationShell,
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
            icon: Semantics(
              label: cartLabel,
              child: cartIcon,
            ),
            selectedIcon: Semantics(
              label: cartLabel,
              child: cartSelectedIcon,
            ),
            label: strings.navCart,
            tooltip: cartLabel,
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

/// GoRouter configuration for the VanRozgar Phase 1 guest-browseable shell and intro landing flow.
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
              builder: (context, state) => const CategoriesPlaceholderPage(),
            ),
          ],
        ),

        // Destination 2: Cart
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cart',
              builder: (context, state) => const CartPlaceholderPage(),
            ),
          ],
        ),

        // Destination 3: Orders
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrdersPlaceholderPage(),
            ),
          ],
        ),

        // Destination 4: Profile
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
