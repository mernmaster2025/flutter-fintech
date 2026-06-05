import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/action_sheets.dart';
import '../widgets/premium_components.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.watch(context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 132),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              AnimatedEntrance(child: _ProfileHero(controller: controller)),
              const SizedBox(height: 22),
              AnimatedEntrance(
                delay: const Duration(milliseconds: 120),
                child: _MembershipCard(controller: controller),
              ),
              const SizedBox(height: 22),
              AnimatedEntrance(
                delay: const Duration(milliseconds: 220),
                child: _SettingsPanel(controller: controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.electricBlue.withValues(alpha: 0.30),
          AppColors.pink.withValues(alpha: 0.20),
          Colors.white.withValues(alpha: 0.08),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.neonGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink.withValues(alpha: 0.34),
                  blurRadius: 36,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Center(
              child: Text(
                controller.profile.name.characters.first,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            controller.profile.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${controller.profile.plan} • ${controller.profile.email}',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              StatusChip(
                label: controller.profile.verified ? 'Verified' : 'Pending',
                color: controller.profile.verified
                    ? AppColors.emerald
                    : AppColors.orange,
                icon: Icons.shield_rounded,
              ),
              StatusChip(
                label: '${controller.orders.length} orders',
                color: AppColors.pink,
                icon: Icons.candlestick_chart_rounded,
              ),
              StatusChip(
                label: '${controller.transfers.length} transfers',
                color: AppColors.cyan,
                icon: Icons.near_me_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final progress = (controller.portfolioValue / 250000).clamp(0.08, 1.0);
    return GlassCard(
      gradient: AppColors.cardGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.diamond_rounded, color: Colors.white, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.profile.plan,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const StatusChip(label: 'Backend-ready', color: AppColors.lime),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Portfolio permissions, trading preferences, alert settings, and card controls are saved locally and ready to map to authenticated APIs.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.toDouble()),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${money(controller.portfolioValue, decimals: 0)} tracked toward private client tier',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.76),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final settings = controller.settings;
    final items = [
      (
        Icons.notifications_active_rounded,
        'Smart alerts',
        'Market, order, and transfer signals',
        AppColors.cyan,
        settings.smartAlerts,
        (bool value) => settings.copyWith(smartAlerts: value),
      ),
      (
        Icons.lock_person_rounded,
        'Biometric approvals',
        'Require device approval before trades',
        AppColors.emerald,
        settings.biometricApprovals,
        (bool value) => settings.copyWith(biometricApprovals: value),
      ),
      (
        Icons.palette_rounded,
        'Dynamic aurora theme',
        'Keep premium animated backgrounds active',
        AppColors.pink,
        settings.dynamicTheme,
        (bool value) => settings.copyWith(dynamicTheme: value),
      ),
      (
        Icons.support_agent_rounded,
        'Concierge',
        'Priority crypto specialist support',
        AppColors.orange,
        settings.concierge,
        (bool value) => settings.copyWith(concierge: value),
      ),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Experience', action: 'Saved locally'),
          for (final item in items) ...[
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.$4.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(item.$1, color: item.$4),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$2,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$3,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: item.$5,
                  activeThumbColor: AppColors.emerald,
                  onChanged: (value) async {
                    final messenger = ScaffoldMessenger.of(context);
                    await controller.updateSettings(item.$6(value));
                    if (controller.message != null) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(controller.message!)),
                      );
                    }
                  },
                ),
              ],
            ),
            if (item != items.last) const SizedBox(height: 18),
          ],
          const SizedBox(height: 20),
          GradientButton(
            label: 'Export account report',
            icon: Icons.file_download_rounded,
            expanded: true,
            onPressed: () => showReportSheet(context),
          ),
        ],
      ),
    );
  }
}
