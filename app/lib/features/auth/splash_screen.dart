import 'dart:async';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/tokens.dart';
import '../../shared/models/user.dart';
import 'auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;
  bool _minTimeElapsed = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _minTimeElapsed = true;
        _checkAndNavigate();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkAndNavigate() {
    if (!_minTimeElapsed || !mounted) return;
    final authState = ref.read(authControllerProvider);
    if (authState is AsyncLoading) return; // Wait until auth state finishes loading

    final user = authState.valueOrNull;
    if (user != null) {
      if (user.role == 'gramsabha') {
        context.go('/gs');
      } else if (user.role == 'buyer') {
        context.go('/b');
      } else if (user.role == 'team') {
        context.go('/team');
      } else {
        context.go('/v');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<UserModel?>>(authControllerProvider, (_, next) {
      if (next is! AsyncLoading && _minTimeElapsed) {
        _checkAndNavigate();
      }
    });
    final tokens = context.vr;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF14452B),
              Color(0xFF1E633E),
              Color(0xFF287D4E),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular emblem (video 00:03)
                Container(
                  width: 94,
                  height: 94,
                  decoration: BoxDecoration(
                    color: const Color(0xFF113224),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE67E22), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE67E22).withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.forest, size: 44, color: Color(0xFFF39C12)),
                  ),
                ),
                const SizedBox(height: 28),
                const VrText(
                  'वनरोजगार',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                VrText(
                  'VanRozgar',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                VrText(
                  'शाश्वत वनोपज व उपजीविका मंच',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                VrText(
                  'Forest Produce & Rural Livelihoods Platform',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 56),
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(tokens.actionPrimary.withValues(alpha: 0.85)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
