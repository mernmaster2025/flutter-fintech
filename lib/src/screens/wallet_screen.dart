import 'package:flutter/material.dart';

import '../models/finance_models.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_components.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedCard = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 132),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedEntrance(child: _WalletHeader(isWide: isWide)),
                  const SizedBox(height: 22),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _CardShowcase(index: _selectedCard)),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _CardControls(
                            selectedCard: _selectedCard,
                            onSelected: (index) {
                              setState(() => _selectedCard = index);
                            },
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _CardShowcase(index: _selectedCard),
                    const SizedBox(height: 20),
                    _CardControls(
                      selectedCard: _selectedCard,
                      onSelected: (index) {
                        setState(() => _selectedCard = index);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WalletHeader extends StatelessWidget {
  const _WalletHeader({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.cyan.withValues(alpha: 0.28),
          AppColors.purple.withValues(alpha: 0.20),
          Colors.white.withValues(alpha: 0.08),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StatusChip(
                  label: 'Apple Wallet ready',
                  color: AppColors.emerald,
                  icon: Icons.phone_iphone_rounded,
                ),
                const SizedBox(height: 18),
                Text(
                  'Cards that adapt to how your team spends.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Create virtual cards, set smart limits, and watch spend controls animate in real time.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          if (isWide) ...[
            const SizedBox(width: 24),
            const Icon(
              Icons.credit_score_rounded,
              color: AppColors.cyan,
              size: 92,
            ),
          ],
        ],
      ),
    );
  }
}

class _CardShowcase extends StatelessWidget {
  const _CardShowcase({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final card = premiumCards[index];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      child: Hero(
        key: ValueKey(card.name),
        tag: 'wallet-${card.name}',
        child: Material(
          color: Colors.transparent,
          child: PremiumPaymentCard(card: card),
        ),
      ),
    );
  }
}

class _CardControls extends StatelessWidget {
  const _CardControls({required this.selectedCard, required this.onSelected});

  final int selectedCard;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Card stack', action: 'Add card'),
              for (var i = 0; i < premiumCards.length; i++) ...[
                _CardSelector(
                  card: premiumCards[i],
                  selected: selectedCard == i,
                  onTap: () => onSelected(i),
                ),
                if (i != premiumCards.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _SecurityControls(),
      ],
    );
  }
}

class _CardSelector extends StatelessWidget {
  const _CardSelector({
    required this.card,
    required this.selected,
    required this.onTap,
  });

  final PremiumCardData card;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 22,
      onTap: onTap,
      gradient: selected
          ? LinearGradient(
              colors: [
                card.accent.withValues(alpha: 0.32),
                Colors.white.withValues(alpha: 0.08),
              ],
            )
          : null,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 34,
            decoration: BoxDecoration(
              gradient: card.gradient,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.name, style: Theme.of(context).textTheme.titleMedium),
                Text(card.number, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          AnimatedScale(
            scale: selected ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.emerald,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityControls extends StatelessWidget {
  const _SecurityControls();

  @override
  Widget build(BuildContext context) {
    final controls = [
      (Icons.lock_rounded, 'Freeze instantly', AppColors.cyan),
      (Icons.radar_rounded, 'Merchant radar', AppColors.pink),
      (Icons.travel_explore_rounded, 'Travel mode', AppColors.orange),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Controls'),
          for (final control in controls) ...[
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: control.$3.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(control.$1, color: control.$3),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    control.$2,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch.adaptive(
                  value: control.$1 != Icons.travel_explore_rounded,
                  activeThumbColor: AppColors.emerald,
                  onChanged: (_) {},
                ),
              ],
            ),
            if (control != controls.last) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
