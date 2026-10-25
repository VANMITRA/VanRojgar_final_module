import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/config/app_config.dart';
import '../../core/security/token_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'data/livelihood_api.dart';
import 'livelihood_routes.dart';
import 'providers/host_hooks.dart';
import 'providers/launch_provider.dart';
import 'providers/market_points.dart';
import '../auth/auth_providers.dart' show apiClientProvider;
import 'providers/livelihood_providers.dart';

/// How the livelihood feature sits inside this app.
///
/// * It talks to its own server (`LIVELIHOOD_API_BASE_URL`) with the SAME sign-in token the
///   marketplace server issued: one sign-in for both.
/// * It is drawn inside the portal shell (header and bottom bar belong to the shell), through the
///   frame hook: each screen of the feature shows only its body, plus a slim title row with a back
///   arrow once it is not the first screen.
final List<Override> livelihoodOverrides = [
  livelihoodApiProvider.overrideWith(
    (ref) => HostApiAdapter(
      ApiClient(
        baseUrl: AppConfig.livelihoodBaseUrl,
        tokenProvider: TokenStore.getToken,
      ),
    ),
  ),
  hostFrameBuilderProvider.overrideWithValue(embeddedLivelihoodFrame),
  // The map's "Marketplace listings" layer reads the marketplace server, which only the host knows about.
  marketPointsLoaderProvider.overrideWith((ref) {
    final api = ref.watch(apiClientProvider);
    return () async {
      final res = await api.get('/listings/map');
      return [
        for (final p in (res['points'] as List? ?? const []))
          MarketPoint.fromJson(Map<String, dynamic>.from(p as Map)),
      ];
    };
  }),
];

/// The frame the shell gives every screen of the feature (public so a test can use it).
Widget embeddedLivelihoodFrame(BuildContext context, LvFrameSpec spec) {
  final c = context.colors;
  final canGoBack = Navigator.of(context).canPop();
  return ColoredBox(
    color: c.scaffoldBg,
    child: Column(
      children: [
        if (canGoBack)
          Material(
            color: AppColors.forestCanopy,
            child: SizedBox(
              height: 48,
              child: Row(
                children: [
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      spec.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title.copyWith(color: Colors.white),
                    ),
                  ),
                  ...spec.actions,
                  const SizedBox(width: AppSpacing.xs),
                ],
              ),
            ),
          ),
        if (spec.bottom != null)
          Material(color: AppColors.forestCanopy, child: spec.bottom!),
        Expanded(child: spec.body),
      ],
    ),
  );
}

/// The livelihood feature with its own navigator, so its screens keep their named routes
/// (`Navigator.pushNamed`) inside this app's router. The Android back button goes back inside the
/// feature first, and leaves it only from its first screen.
class LivelihoodShell extends ConsumerStatefulWidget {
  const LivelihoodShell({super.key, this.launch});

  /// Where the person came from (a marketplace listing), from the route's query parameters.
  final LivelihoodLaunch? launch;

  @override
  ConsumerState<LivelihoodShell> createState() => _LivelihoodShellState();
}

class _LivelihoodShellState extends ConsumerState<LivelihoodShell> {
  final GlobalKey<NavigatorState> _navigator = GlobalKey<NavigatorState>();

  void _publishLaunch() {
    final launch = widget.launch;
    if (launch == null || launch.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(livelihoodLaunchProvider.notifier).state = launch;
    });
  }

  @override
  void initState() {
    super.initState();
    _publishLaunch();
  }

  @override
  void didUpdateWidget(LivelihoodShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.launch != widget.launch) _publishLaunch();
  }

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      // ignore: deprecated_member_use -- onPopWithResult changes when this is called and breaks back inside the feature
      onPop: () => _navigator.currentState?.maybePop(),
      child: Navigator(
        key: _navigator,
        initialRoute: LivelihoodRoutes.home,
        onGenerateRoute: (settings) {
          final build = livelihoodRoutes[settings.name];
          if (build == null) return null;
          return MaterialPageRoute<void>(settings: settings, builder: build);
        },
      ),
    );
  }
}
