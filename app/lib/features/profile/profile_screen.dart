import 'package:flutter/material.dart';
import '../../shared/widgets/vr_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/profile_hero.dart';
import '../../shared/widgets/preference_card.dart';
import '../../shared/widgets/appearance_sheet.dart';
import '../../shared/widgets/breadcrumb.dart';
import '../../shared/widgets/sync_diagnostics_card.dart';
import '../auth/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).asData?.value;

    if (user == null) {
      return const Scaffold(body: Center(child: VrText('लॉगिन नाही • Not logged in')));
    }

    return Scaffold(
      appBar: AppBar(title: const VrText('प्रोफाइल व सेटिंग्ज • Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Breadcrumb(segments: ['मुख्यपृष्ठ • Home', 'प्रोफाइल • Profile']),
              ProfileHero(user: user),
              const SyncDiagnosticsCard(),
              const SizedBox(height: 8),
              PreferenceCard(
                icon: Icons.palette_outlined,
                title: 'स्वरूप व थीम (Appearance)',
                subtitle: 'हलकी / गडद थीम (Light / Dark Mode)',
                onTap: () => AppearanceSheet.show(context),
              ),
              PreferenceCard(
                icon: Icons.language,
                title: 'भाषा बदला (Change Language)',
                subtitle: const {'en': 'English', 'hi': 'हिंदी', 'mr': 'मराठी'}[ref.watch(activeLocaleProvider)] ?? 'English',
                onTap: () => context.push('/settings/language'),
              ),
              PreferenceCard(
                icon: Icons.notifications_none,
                title: 'सूचना आणि अपडेट्स (Messages)',
                subtitle: 'व्यवहार व ऑर्डरच्या ताज्या सूचना पहा',
                onTap: () => context.push('/messages'),
              ),
              PreferenceCard(
                icon: Icons.help_outline,
                title: 'मदत व संपर्क (Help & Support)',
                subtitle: 'हेल्पलाईन आणि मार्गदर्शन केंद्र',
                onTap: () => context.push('/help/forgot-password'),
              ),
              PreferenceCard(
                icon: Icons.info_outline,
                title: 'माहिती व गोपनीयता (About & Privacy)',
                subtitle: 'श्रेय, डेटा स्रोत व गोपनीयता (Credits, data, privacy)',
                onTap: () => context.push('/about'),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const VrText(
                    'लॉगआउट करा • Logout',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
