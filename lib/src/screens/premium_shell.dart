import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/premium_components.dart';
import 'analytics_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'payments_screen.dart';
import 'profile_screen.dart';
import 'wallet_screen.dart';

class PremiumShell extends StatefulWidget {
  const PremiumShell({super.key});

  @override
  State<PremiumShell> createState() => _PremiumShellState();
}

class _PremiumShellState extends State<PremiumShell> {
  int _selectedIndex = 0;

  static const _items = [
    NavigationItem(icon: Icons.grid_view_rounded, label: 'Home'),
    NavigationItem(icon: Icons.query_stats_rounded, label: 'Pulse'),
    NavigationItem(icon: Icons.credit_card_rounded, label: 'Cards'),
    NavigationItem(icon: Icons.near_me_rounded, label: 'Pay'),
    NavigationItem(icon: Icons.person_rounded, label: 'You'),
  ];

  late final List<Widget> _screens = const [
    DashboardScreen(),
    AnalyticsScreen(),
    WalletScreen(),
    PaymentsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AuroraBackground(
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 460),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final offset = Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offset,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.98,
                          end: 1,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_selectedIndex),
                  child: _screens[_selectedIndex],
                ),
              ),
            ),
            IgnorePointer(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 170,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.midnight.withValues(alpha: 0.88),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: PremiumBottomNav(
                    items: _items,
                    selectedIndex: _selectedIndex,
                    onSelected: (index) =>
                        setState(() => _selectedIndex = index),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
