import 'package:flutter/material.dart';

import '../models/finance_models.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/action_sheets.dart';
import '../widgets/premium_components.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.watch(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 860;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 132),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedEntrance(
                    child: _AnalyticsHero(
                      controller: controller,
                      isWide: isWide,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _PortfolioChart(controller: controller),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          flex: 4,
                          child: _SignalColumn(controller: controller),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _PortfolioChart(controller: controller),
                        const SizedBox(height: 18),
                        _SignalColumn(controller: controller),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnalyticsHero extends StatelessWidget {
  const _AnalyticsHero({required this.controller, required this.isWide});

  final AppController controller;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final narrative = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StatusChip(
          label: 'Predictive crypto pulse',
          color: AppColors.pink,
          icon: Icons.auto_awesome_rounded,
        ),
        const SizedBox(height: 22),
        Text(
          'Portfolio intelligence backed by live mock market state.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Allocation, P/L, risk, watchlist, and activity are computed from persisted holdings and simulated market ticks.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 18),
        GradientButton(
          label: 'Export report',
          icon: Icons.file_download_rounded,
          onPressed: () => showReportSheet(context),
        ),
      ],
    );
    final metrics = Row(
      children: [
        Expanded(
          child: _RadialMetric(
            label: 'Return',
            value: percent(controller.unrealizedPnLPercent),
            progress: (controller.unrealizedPnLPercent.abs() / 100).clamp(
              0.08,
              1,
            ),
            color: controller.unrealizedPnL >= 0
                ? AppColors.emerald
                : AppColors.pink,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _RadialMetric(
            label: 'Crypto',
            value: compactMoney(controller.cryptoValue),
            progress: (controller.cryptoValue / controller.portfolioValue)
                .clamp(0, 1),
            color: AppColors.cyan,
          ),
        ),
      ],
    );

    return GlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.purple.withValues(alpha: 0.34),
          AppColors.cyan.withValues(alpha: 0.14),
          Colors.white.withValues(alpha: 0.08),
        ],
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: narrative),
                const SizedBox(width: 28),
                Expanded(flex: 4, child: metrics),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [narrative, const SizedBox(height: 24), metrics],
            ),
    );
  }
}

class _PortfolioChart extends StatelessWidget {
  const _PortfolioChart({required this.controller});

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

    return AnimatedEntrance(
      delay: const Duration(milliseconds: 120),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Portfolio allocation',
              action: 'Computed',
            ),
            SpendingChart(points: points, height: 260),
            const SizedBox(height: 16),
            Text(
              '${money(controller.cashBalance)} cash available. ${signedMoney(controller.unrealizedPnL)} unrealized P/L across ${controller.holdings.length} positions.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalColumn extends StatelessWidget {
  const _SignalColumn({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final concentration = controller.holdings.isEmpty
        ? 0.0
        : controller.holdings
                  .map((holding) => controller.holdingValue(holding.assetId))
                  .reduce((a, b) => a > b ? a : b) /
              controller.cryptoValue *
              100;
    final risk = concentration > 60
        ? 'High'
        : concentration > 45
        ? 'Medium'
        : 'Low';

    return Column(
      children: [
        AnimatedEntrance(
          delay: const Duration(milliseconds: 160),
          child: StatWidget(
            label: 'Daily movement',
            value: signedMoney(controller.dailyChangeUsd),
            delta: percent(controller.dailyChangePercent),
            color: controller.dailyChangeUsd >= 0
                ? AppColors.emerald
                : AppColors.pink,
            icon: Icons.ssid_chart_rounded,
          ),
        ),
        const SizedBox(height: 16),
        AnimatedEntrance(
          delay: const Duration(milliseconds: 220),
          child: StatWidget(
            label: 'Risk exposure',
            value: risk,
            delta: '${concentration.toStringAsFixed(0)}% top',
            color: AppColors.cyan,
            icon: Icons.shield_rounded,
          ),
        ),
        const SizedBox(height: 16),
        AnimatedEntrance(
          delay: const Duration(milliseconds: 280),
          child: StatWidget(
            label: 'Executed orders',
            value: '${controller.orders.length}',
            delta: '${controller.transfers.length} rails',
            color: AppColors.purple,
            icon: Icons.candlestick_chart_rounded,
          ),
        ),
      ],
    );
  }
}

class _RadialMetric extends StatelessWidget {
  const _RadialMetric({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, _) {
        return AspectRatio(
          aspectRatio: 1,
          child: CustomPaint(
            painter: _RingPainter(progress: animatedProgress, color: color),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(value, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 10;
    final background = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final foreground = Paint()
      ..shader = SweepGradient(
        colors: [color, AppColors.pink, color],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, background);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57,
      progress * 6.28,
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
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
