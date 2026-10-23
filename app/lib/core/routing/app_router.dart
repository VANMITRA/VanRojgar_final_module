import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/vr_header.dart';
import '../../shared/widgets/vr_bottom_nav.dart';
import '../../shared/widgets/footer_strip.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/language_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_portal_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/gramsabha/gs_home_screen.dart';
import '../../features/gramsabha/gs_listings_screen.dart';
import '../../features/gramsabha/add_edit_listing_screen.dart';
import '../../features/gramsabha/gs_requests_screen.dart';
import '../../features/gramsabha/gs_orders_screen.dart';
import '../../features/villager/villager_home_screen.dart';
import '../../features/buyer/buyer_home_screen.dart';
import '../../features/listings/listing_detail_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/gramsabhas/gs_profile_screen.dart';
import '../../features/trade/order_detail_screen.dart';
import '../../features/messages/messages_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/delivery/delivery_intro_screen.dart';
import '../../features/delivery/delivery_hub_screen.dart';
import '../../features/delivery/delivery_apply_screen.dart';
import '../../features/delivery/delivery_jobs_screen.dart';
import '../../features/barter/barter_sheet.dart';
import '../../features/barter/barter_offers_screen.dart';
import '../../features/team/team_tools_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../features/auth/auth_providers.dart';

class PortalShell extends ConsumerStatefulWidget {
  final Widget child;
  final String portal; // 'gs' | 'v' | 'b'

  const PortalShell({super.key, required this.child, required this.portal});

  @override
  ConsumerState<PortalShell> createState() => _PortalShellState();
}

class _PortalShellState extends ConsumerState<PortalShell> {
  List<VrNavItem> _getNavItems(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.portal == 'gs') {
      return [
        VrNavItem(icon: Icons.dashboard_outlined, label: l10n?.home ?? 'मुख्यपृष्ठ'),
        VrNavItem(icon: Icons.inventory_2_outlined, label: l10n?.listings ?? 'उत्पादने'),
        VrNavItem(icon: Icons.inbox_outlined, label: l10n?.requests ?? 'मागण्या'),
        VrNavItem(icon: Icons.local_shipping_outlined, label: l10n?.orders ?? 'ऑर्डर्स'),
        VrNavItem(icon: Icons.person_outline, label: l10n?.profile ?? 'प्रोफाइल'),
      ];
    } else if (widget.portal == 'b') {
      return [
        VrNavItem(icon: Icons.home_outlined, label: l10n?.home ?? 'Home'),
        VrNavItem(icon: Icons.search, label: l10n?.search ?? 'Search'),
        VrNavItem(icon: Icons.inbox_outlined, label: l10n?.requests ?? 'Requests'),
        VrNavItem(icon: Icons.shopping_bag_outlined, label: l10n?.orders ?? 'Orders'),
        VrNavItem(icon: Icons.person_outline, label: l10n?.profile ?? 'Profile'),
      ];
    } else {
      return [
        VrNavItem(icon: Icons.home_outlined, label: l10n?.home ?? 'मुख्यपृष्ठ'),
        VrNavItem(icon: Icons.search, label: l10n?.search ?? 'शोधा'),
        VrNavItem(icon: Icons.inbox_outlined, label: l10n?.requests ?? 'मागण्या'),
        VrNavItem(icon: Icons.shopping_bag_outlined, label: l10n?.orders ?? 'ऑर्डर्स'),
        VrNavItem(icon: Icons.person_outline, label: l10n?.profile ?? 'प्रोफाइल'),
      ];
    }
  }

  int _calculateIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (widget.portal == 'gs') {
      if (location.startsWith('/gs/listings')) return 1;
      if (location.startsWith('/gs/requests')) return 2;
      if (location.startsWith('/gs/orders')) return 3;
      if (location.startsWith('/gs/profile')) return 4;
      return 0;
    } else if (widget.portal == 'b') {
      if (location.startsWith('/b/search')) return 1;
      if (location.startsWith('/b/requests')) return 2;
      if (location.startsWith('/b/orders')) return 3;
      if (location.startsWith('/b/profile')) return 4;
      return 0;
    } else {
      if (location.startsWith('/v/search')) return 1;
      if (location.startsWith('/v/requests')) return 2;
      if (location.startsWith('/v/orders')) return 3;
      if (location.startsWith('/v/profile')) return 4;
      return 0;
    }
  }

  void _onNavTap(int index) {
    final base = widget.portal;

    if (base == 'gs') {
      switch (index) {
        case 0: context.go('/gs'); break;
        case 1: context.go('/gs/listings'); break;
        case 2: context.go('/gs/requests'); break;
        case 3: context.go('/gs/orders'); break;
        case 4: context.go('/gs/profile'); break;
      }
    } else if (base == 'b') {
      switch (index) {
        case 0: context.go('/b'); break;
        case 1: context.go('/b/search'); break;
        case 2: context.go('/b/requests'); break;
        case 3: context.go('/b/orders'); break;
        case 4: context.go('/b/profile'); break;
      }
    } else {
      switch (index) {
        case 0: context.go('/v'); break;
        case 1: context.go('/v/search'); break;
        case 2: context.go('/v/requests'); break;
        case 3: context.go('/v/orders'); break;
        case 4: context.go('/v/profile'); break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).asData?.value;
    String sub = 'harsul_trimbak_nashik';
    if (user != null) {
      if (widget.portal == 'b') {
        final city = (user.city ?? 'nashik').toLowerCase().replaceAll(' ', '_');
        sub = '${city}_procurement_${user.district.toLowerCase()}';
      } else {
        final v = (user.village ?? 'harsul').toLowerCase().replaceAll(' ', '_');
        final t = (user.taluka ?? 'trimbak').toLowerCase().replaceAll(' ', '_');
        final d = user.district.toLowerCase().replaceAll(' ', '_');
        sub = '${v}_${t}_${d}';
      }
    }

    final activeLocale = ref.watch(activeLocaleProvider);

    return Scaffold(
      appBar: VrHeader(
        title: 'VanRozgar | वनरोजगार',
        subtitle: sub,
        activeLanguage: activeLocale,
        onLanguageChanged: (lang) => ref.read(activeLocaleProvider.notifier).setLanguage(lang),
      ),
      body: widget.child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FooterStrip(),
          VrBottomNav(
            currentIndex: _calculateIndex(context),
            onTap: _onNavTap,
            items: _getNavItems(context),
          ),
        ],
      ),
    );
  }
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/language', builder: (_, __) => const LanguageScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPortalScreen()),
    GoRoute(
      path: '/register/:portal',
      builder: (_, state) => RegisterScreen(portal: state.pathParameters['portal'] ?? 'villager'),
    ),
    GoRoute(path: '/help/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),

    // Gram Sabha Shell Routes
    ShellRoute(
      builder: (_, __, child) => PortalShell(portal: 'gs', child: child),
      routes: [
        GoRoute(path: '/gs', builder: (_, __) => const GsHomeScreen()),
        GoRoute(path: '/gs/listings', builder: (_, __) => const GsListingsScreen()),
        GoRoute(path: '/gs/requests', builder: (_, __) => const GsRequestsScreen()),
        GoRoute(path: '/gs/orders', builder: (_, __) => const GsOrdersScreen()),
        GoRoute(path: '/gs/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),

    // Villager Shell Routes
    ShellRoute(
      builder: (_, __, child) => PortalShell(portal: 'v', child: child),
      routes: [
        GoRoute(path: '/v', builder: (_, __) => const VillagerHomeScreen()),
        GoRoute(path: '/v/search', builder: (_, __) => const SearchScreen()),
        GoRoute(path: '/v/requests', builder: (_, __) => const GsRequestsScreen()),
        GoRoute(path: '/v/orders', builder: (_, __) => const GsOrdersScreen()),
        GoRoute(path: '/v/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),

    // Buyer Shell Routes
    ShellRoute(
      builder: (_, __, child) => PortalShell(portal: 'b', child: child),
      routes: [
        GoRoute(path: '/b', builder: (_, __) => const BuyerHomeScreen()),
        GoRoute(path: '/b/search', builder: (_, __) => const SearchScreen()),
        GoRoute(path: '/b/requests', builder: (_, __) => const GsRequestsScreen()),
        GoRoute(path: '/b/orders', builder: (_, __) => const GsOrdersScreen()),
        GoRoute(path: '/b/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),

    // Shared Details & Modals
    GoRoute(path: '/gs/listings/new', builder: (_, __) => const AddEditListingScreen()),
    GoRoute(
      path: '/gs/listings/:id/edit',
      builder: (_, state) => AddEditListingScreen(listingId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/listings/:id',
      builder: (_, state) => ListingDetailScreen(listingId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/gramsabhas/:id',
      builder: (_, state) => GsProfileScreen(gramSabhaId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/orders/:id',
      builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/messages', builder: (_, __) => const MessagesScreen()),
    GoRoute(path: '/settings/language', builder: (_, __) => const LanguageScreen()),

    // Delivery Livelihood Flow
    GoRoute(path: '/delivery', builder: (_, __) => const DeliveryHubScreen()),
    GoRoute(path: '/delivery/intro', builder: (_, __) => const DeliveryIntroScreen()),
    GoRoute(path: '/delivery/apply', builder: (_, __) => const DeliveryApplyScreen()),
    GoRoute(path: '/delivery/jobs', builder: (_, __) => const DeliveryJobsScreen()),

    // Barter Flow
    GoRoute(
      path: '/barter/new/:id',
      builder: (_, state) => BarterSheetScreen(listingId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/barter/offers',
      builder: (_, __) => const BarterOffersScreen(),
    ),

    // Back Office Team Tools
    GoRoute(path: '/team', builder: (_, __) => const TeamToolsScreen()),
  ],
);
