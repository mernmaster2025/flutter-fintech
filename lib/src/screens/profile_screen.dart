import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/premium_components.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 132),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: const [
              AnimatedEntrance(child: _ProfileHero()),
              SizedBox(height: 22),
              AnimatedEntrance(
                delay: Duration(milliseconds: 120),
                child: _MembershipCard(),
              ),
              SizedBox(height: 22),
              AnimatedEntrance(
                delay: Duration(milliseconds: 220),
                child: _SettingsPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero();

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
                'A',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Alex Morgan',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Founder plan • Verified treasury account',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              StatusChip(
                label: 'Security 98',
                color: AppColors.emerald,
                icon: Icons.shield_rounded,
              ),
              StatusChip(
                label: 'Premium',
                color: AppColors.pink,
                icon: Icons.workspace_premium_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard();

  @override
  Widget build(BuildContext context) {
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
                  'Astra Infinite',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const StatusChip(label: 'Elite', color: AppColors.lime),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Priority support, advanced limits, treasury sweeps, and early access to AI money movement.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 0.82),
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
            '82% to next reward tier',
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
  const _SettingsPanel();

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.notifications_active_rounded,
        'Smart alerts',
        'Only the signals that matter',
        AppColors.cyan,
      ),
      (
        Icons.lock_person_rounded,
        'Privacy vault',
        'Biometric approvals and device trust',
        AppColors.emerald,
      ),
      (
        Icons.palette_rounded,
        'Appearance',
        'Dynamic aurora theme enabled',
        AppColors.pink,
      ),
      (
        Icons.support_agent_rounded,
        'Concierge',
        'Priority fintech specialist',
        AppColors.orange,
      ),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Experience'),
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
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            if (item != items.last) const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}
