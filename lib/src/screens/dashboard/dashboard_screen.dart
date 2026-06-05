import 'package:flutter/material.dart';

import '../../domain/crypto_models.dart';
import '../../models/finance_models.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/action_sheets.dart';
import '../../widgets/premium_components.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _balanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.watch(context);
    return RefreshIndicator(
      color: AppColors.cyan,
      backgroundColor: AppColors.ink,
      onRefresh: controller.refresh,
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
                    AnimatedEntrance(
                      child: _DashboardHeader(controller: controller),
                    ),
                    const SizedBox(height: 22),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _PrimaryColumn(
                              controller: controller,
                              balanceVisible: _balanceVisible,
                              onToggleBalance: () {
                                setState(
                                  () => _balanceVisible = !_balanceVisible,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 22),
                          Expanded(
                            flex: 4,
                            child: _SecondaryColumn(controller: controller),
                          ),
                        ],
                      )
                    else ...[
                      _PrimaryColumn(
                        controller: controller,
                        balanceVisible: _balanceVisible,
                        onToggleBalance: () {
                          setState(() => _balanceVisible = !_balanceVisible);
                        },
                      ),
                      const SizedBox(height: 22),
                      _SecondaryColumn(controller: controller),
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
  const _DashboardHeader({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, ${controller.profile.name.split(' ').first}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Your crypto portfolio is live across mock backend markets.',
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
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.purple,
                child: Text(
                  controller.profile.name.characters.first,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: controller.profile.verified
                        ? AppColors.emerald
                        : AppColors.orange,
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
    required this.controller,
    required this.balanceVisible,
    required this.onToggleBalance,
  });

  final AppController controller;
  final bool balanceVisible;
  final VoidCallback onToggleBalance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedEntrance(
          delay: const Duration(milliseconds: 80),
          child: _BalanceCard(
            controller: controller,
            balanceVisible: balanceVisible,
            onToggleBalance: onToggleBalance,
          ),
        ),
        const SizedBox(height: 18),
        AnimatedEntrance(
          delay: const Duration(milliseconds: 160),
          child: _QuickActions(controller: controller),
        ),
        const SizedBox(height: 22),
        AnimatedEntrance(
          delay: const Duration(milliseconds: 230),
          child: _PortfolioAllocation(controller: controller),
        ),
      ],
    );
  }
}

class _SecondaryColumn extends StatelessWidget {
  const _SecondaryColumn({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedEntrance(
          delay: const Duration(milliseconds: 120),
          child: _Watchlist(controller: controller),
        ),
        const SizedBox(height: 22),
        AnimatedEntrance(
          delay: const Duration(milliseconds: 240),
          child: _Insights(controller: controller),
        ),
        const SizedBox(height: 22),
        AnimatedEntrance(
          delay: const Duration(milliseconds: 320),
          child: _ActivityTimeline(controller: controller),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.controller,
    required this.balanceVisible,
    required this.onToggleBalance,
  });

  final AppController controller;
  final bool balanceVisible;
  final VoidCallback onToggleBalance;

  @override
  Widget build(BuildContext context) {
    final gainColor = controller.dailyChangeUsd >= 0
        ? AppColors.emerald
        : AppColors.pink;
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
              StatusChip(
                label: controller.busy ? 'Syncing backend' : 'Live portfolio',
                color: controller.busy ? AppColors.orange : AppColors.cyan,
                icon: controller.busy
                    ? Icons.sync_rounded
                    : Icons.verified_rounded,
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
                    value: controller.portfolioValue,
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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              StatusChip(
                label:
                    '${signedMoney(controller.dailyChangeUsd)} today • ${percent(controller.dailyChangePercent)}',
                color: gainColor,
                icon: controller.dailyChangeUsd >= 0
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
              ),
              StatusChip(
                label: '${money(controller.cashBalance)} cash',
                color: AppColors.cyan,
                icon: Icons.account_balance_wallet_rounded,
              ),
            ],
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              GradientButton(
                label: 'Buy crypto',
                icon: Icons.add_chart_rounded,
                gradient: AppColors.successGradient,
                onPressed: () => showOrderSheet(context, side: OrderSide.buy),
              ),
              GradientButton(
                label: 'Sell',
                icon: Icons.trending_down_rounded,
                gradient: AppColors.warmGradient,
                onPressed: () => showOrderSheet(context, side: OrderSide.sell),
              ),
              GradientButton(
                label: 'Move money',
                icon: Icons.near_me_rounded,
                onPressed: () => showTransferSheet(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        Icons.bolt_rounded,
        'Refresh',
        AppColors.cyan,
        () async {
          final messenger = ScaffoldMessenger.of(context);
          await controller.refresh();
          if (controller.message != null) {
            messenger.showSnackBar(
              SnackBar(content: Text(controller.message!)),
            );
          }
        },
      ),
      (
        Icons.auto_awesome_rounded,
        'AI optimize',
        AppColors.purple,
        () async {
          final messenger = ScaffoldMessenger.of(context);
          await controller.addSystemActivity(
            'AI rebalance prepared',
            'Suggested BTC 48%, ETH 32%, SOL 14%, LINK 6%',
          );
          if (controller.message != null) {
            messenger.showSnackBar(
              SnackBar(content: Text(controller.message!)),
            );
          }
        },
      ),
      (
        Icons.receipt_long_rounded,
        'Report',
        AppColors.emerald,
        () => showReportSheet(context),
      ),
      (
        Icons.notifications_active_rounded,
        'Alerts',
        AppColors.orange,
        () async {
          final messenger = ScaffoldMessenger.of(context);
          await controller.addSystemActivity(
            'Price alert created',
            'Watching ${controller.assets.first.symbol} volatility above 5%',
          );
          if (controller.message != null) {
            messenger.showSnackBar(
              SnackBar(content: Text(controller.message!)),
            );
          }
        },
      ),
    ];

    return Row(
      children: [
        for (final action in actions) ...[
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 16),
              borderRadius: 24,
              onTap: action.$4,
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

class _PortfolioAllocation extends StatelessWidget {
  const _PortfolioAllocation({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final points = [
      for (final holding in controller.holdings)
        ChartPoint(
          controller.assetFor(holding.assetId).symbol,
          controller.cryptoValue == 0
              ? 0
              : controller.holdingValue(holding.assetId) /
                    controller.cryptoValue,
          _assetColor(holding.assetId),
        ),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Allocation pulse', action: 'Live'),
          SpendingChart(points: points),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final point in points)
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

class _Watchlist extends StatelessWidget {
  const _Watchlist({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Market watch', action: 'Tap asset'),
        for (final asset in controller.watchlist) ...[
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: 24,
            onTap: () => showAssetDetailSheet(context, asset),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_assetColor(asset.id), AppColors.purple],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      asset.symbol.characters.take(1).toString(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${asset.symbol} • ${compactMoney(asset.marketCap)} cap',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      money(asset.price),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      percent(asset.change24h),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: asset.change24h >= 0
                            ? AppColors.emerald
                            : AppColors.pink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _Insights extends StatelessWidget {
  const _Insights({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final concentration = controller.holdings.isEmpty
        ? 0
        : controller.holdings
                  .map((holding) => controller.holdingValue(holding.assetId))
                  .reduce((a, b) => a > b ? a : b) /
              controller.cryptoValue *
              100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'AI insights'),
        InsightCard(
          insight: InsightData(
            title: 'Rebalance signal',
            detail:
                'Largest holding is ${concentration.toStringAsFixed(0)}% of crypto exposure. Mock AI suggests keeping it below 55%.',
            value: '${controller.holdings.length} assets',
            gradient: AppColors.primaryGradient,
            icon: Icons.psychology_alt_rounded,
          ),
        ),
        const SizedBox(height: 14),
        InsightCard(
          insight: InsightData(
            title: 'Profit engine',
            detail:
                'Unrealized performance is ${percent(controller.unrealizedPnLPercent)} across current holdings.',
            value: signedMoney(controller.unrealizedPnL),
            gradient: AppColors.successGradient,
            icon: Icons.bolt_rounded,
          ),
        ),
      ],
    );
  }
}

class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Live activity', action: 'Persisted'),
        for (final activity in controller.activities.take(6)) ...[
          GlassCard(
            padding: const EdgeInsets.all(14),
            borderRadius: 24,
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: activityColor(activity.type).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: activityColor(
                        activity.type,
                      ).withValues(alpha: 0.28),
                    ),
                  ),
                  child: Icon(
                    activityIcon(activity.type),
                    color: activityColor(activity.type),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${activity.subtitle} • ${relativeTime(activity.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  activity.amount == 0 ? 'Live' : signedMoney(activity.amount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: activity.amount >= 0
                        ? AppColors.emerald
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

Color _assetColor(String assetId) {
  return switch (assetId) {
    'btc' => AppColors.orange,
    'eth' => AppColors.cyan,
    'sol' => AppColors.purple,
    'link' => AppColors.emerald,
    _ => AppColors.pink,
  };
}
