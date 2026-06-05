import 'package:flutter/material.dart';

import '../../models/finance_models.dart';
import '../../theme/app_colors.dart';
import '../../widgets/premium_components.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _balanceVisible = true;

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.cyan,
      backgroundColor: AppColors.ink,
      onRefresh: _refresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 920;
          final horizontalPadding = isWide ? 32.0 : 18.0;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              12,
              horizontalPadding,
              132,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AnimatedEntrance(child: _DashboardHeader()),
                    const SizedBox(height: 22),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _PrimaryColumn(
                              balanceVisible: _balanceVisible,
                              onToggleBalance: () {
                                setState(
                                  () => _balanceVisible = !_balanceVisible,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 22),
                          const Expanded(flex: 4, child: _SecondaryColumn()),
                        ],
                      )
                    else ...[
                      _PrimaryColumn(
                        balanceVisible: _balanceVisible,
                        onToggleBalance: () {
                          setState(() => _balanceVisible = !_balanceVisible);
                        },
                      ),
                      const SizedBox(height: 22),
                      const _SecondaryColumn(),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, Alex',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Your money is moving beautifully today.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        GlassCard(
          padding: const EdgeInsets.all(10),
          borderRadius: 22,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.purple,
                child: Text('A', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.emerald,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.midnight, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrimaryColumn extends StatelessWidget {
  const _PrimaryColumn({
    required this.balanceVisible,
    required this.onToggleBalance,
  });

  final bool balanceVisible;
  final VoidCallback onToggleBalance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedEntrance(
          delay: const Duration(milliseconds: 80),
          child: _BalanceCard(
            balanceVisible: balanceVisible,
            onToggleBalance: onToggleBalance,
          ),
        ),
        const SizedBox(height: 18),
        const AnimatedEntrance(
          delay: Duration(milliseconds: 160),
          child: _QuickActions(),
        ),
        const SizedBox(height: 22),
        const AnimatedEntrance(
          delay: Duration(milliseconds: 230),
          child: _SpendingOverview(),
        ),
      ],
    );
  }
}

class _SecondaryColumn extends StatelessWidget {
  const _SecondaryColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        AnimatedEntrance(
          delay: Duration(milliseconds: 120),
          child: _CardStack(),
        ),
        SizedBox(height: 22),
        AnimatedEntrance(
          delay: Duration(milliseconds: 240),
          child: _Insights(),
        ),
        SizedBox(height: 22),
        AnimatedEntrance(
          delay: Duration(milliseconds: 320),
          child: _TransactionTimeline(),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balanceVisible,
    required this.onToggleBalance,
  });

  final bool balanceVisible;
  final VoidCallback onToggleBalance;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.electricBlue.withValues(alpha: 0.42),
          AppColors.purple.withValues(alpha: 0.24),
          Colors.white.withValues(alpha: 0.08),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const StatusChip(
                label: 'Premium Treasury',
                color: AppColors.cyan,
                icon: Icons.verified_rounded,
              ),
              const Spacer(),
              IconButton(
                onPressed: onToggleBalance,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Icon(
                    balanceVisible
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    key: ValueKey(balanceVisible),
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: balanceVisible
                ? AnimatedCounter(
                    key: const ValueKey('visible-balance'),
                    value: accountSnapshot.balance,
                    prefix: r'$',
                    decimals: 2,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.4,
                    ),
                  )
                : Text(
                    '••••••••',
                    key: const ValueKey('hidden-balance'),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            '+${accountSnapshot.delta}% this month • \$${accountSnapshot.cashback.toStringAsFixed(0)} cashback unlocked',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              GradientButton(
                label: 'Move money',
                icon: Icons.near_me_rounded,
                onPressed: () {},
              ),
              GradientButton(
                label: 'AI optimize',
                icon: Icons.auto_awesome_rounded,
                gradient: AppColors.successGradient,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.bolt_rounded, 'Instant pay', AppColors.cyan),
      (Icons.swap_horiz_rounded, 'Exchange', AppColors.purple),
      (Icons.savings_rounded, 'Vaults', AppColors.emerald),
      (Icons.receipt_long_rounded, 'Invoices', AppColors.orange),
    ];

    return Row(
      children: [
        for (final action in actions) ...[
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 16),
              borderRadius: 24,
              onTap: () {},
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: action.$3.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(action.$1, color: action.$3),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    action.$2,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (action != actions.last) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _SpendingOverview extends StatelessWidget {
  const _SpendingOverview();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Spending pulse', action: 'Details'),
          const SpendingChart(points: spendingBreakdown),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final point in spendingBreakdown)
                StatusChip(
                  label: '${point.label} ${(point.value * 100).round()}%',
                  color: point.color,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardStack extends StatefulWidget {
  const _CardStack();

  @override
  State<_CardStack> createState() => _CardStackState();
}

class _CardStackState extends State<_CardStack> {
  final _controller = PageController(viewportFraction: 0.92);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Wallet', action: 'Manage'),
        SizedBox(
          height: 238,
          child: PageView.builder(
            controller: _controller,
            itemCount: premiumCards.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) {
              return AnimatedScale(
                scale: _index == index ? 1 : 0.94,
                duration: const Duration(milliseconds: 240),
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Hero(
                    tag: 'card-${premiumCards[index].name}',
                    child: Material(
                      color: Colors.transparent,
                      child: PremiumPaymentCard(card: premiumCards[index]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Insights extends StatelessWidget {
  const _Insights();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'AI insights'),
        for (final insight in insights) ...[
          InsightCard(insight: insight),
          if (insight != insights.last) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _TransactionTimeline extends StatelessWidget {
  const _TransactionTimeline();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Live activity', action: 'View all'),
        for (final transaction in transactions) ...[
          PremiumTransactionTile(transaction: transaction),
          if (transaction != transactions.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
