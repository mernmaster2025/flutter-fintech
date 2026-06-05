import 'package:flutter/material.dart';

import '../models/finance_models.dart';
import '../theme/app_colors.dart';
import '../widgets/premium_components.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  AnimatedEntrance(child: _AnalyticsHero(isWide: isWide)),
                  const SizedBox(height: 20),
                  if (isWide)
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: _CashflowCard()),
                        SizedBox(width: 18),
                        Expanded(flex: 4, child: _SignalColumn()),
                      ],
                    )
                  else
                    const Column(
                      children: [
                        _CashflowCard(),
                        SizedBox(height: 18),
                        _SignalColumn(),
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
  const _AnalyticsHero({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final narrative = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StatusChip(
          label: 'Predictive pulse',
          color: AppColors.pink,
          icon: Icons.auto_awesome_rounded,
        ),
        const SizedBox(height: 22),
        Text(
          'Your financial graph is compounding faster than planned.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Revenue velocity, burn, and treasury yield are all trending in the top quartile.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
    const metrics = Row(
      children: [
        Expanded(
          child: _RadialMetric(
            label: 'Runway',
            value: '26m',
            progress: 0.82,
            color: AppColors.emerald,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _RadialMetric(
            label: 'Burn',
            value: '-12%',
            progress: 0.64,
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
                const Expanded(flex: 4, child: metrics),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [narrative, const SizedBox(height: 24), metrics],
            ),
    );
  }
}

class _CashflowCard extends StatelessWidget {
  const _CashflowCard();

  @override
  Widget build(BuildContext context) {
    return AnimatedEntrance(
      delay: const Duration(milliseconds: 120),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Cashflow intelligence',
              action: 'Export',
            ),
            const SpendingChart(points: spendingBreakdown, height: 260),
            const SizedBox(height: 16),
            Text(
              'AI detected a 19% improvement in net cashflow after recurring vendor optimization.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalColumn extends StatelessWidget {
  const _SignalColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        AnimatedEntrance(
          delay: Duration(milliseconds: 160),
          child: StatWidget(
            label: 'Treasury yield',
            value: r'$8.4k',
            delta: '+22%',
            color: AppColors.emerald,
            icon: Icons.ssid_chart_rounded,
          ),
        ),
        SizedBox(height: 16),
        AnimatedEntrance(
          delay: Duration(milliseconds: 220),
          child: StatWidget(
            label: 'Card efficiency',
            value: '94%',
            delta: '+8%',
            color: AppColors.cyan,
            icon: Icons.speed_rounded,
          ),
        ),
        SizedBox(height: 16),
        AnimatedEntrance(
          delay: Duration(milliseconds: 280),
          child: StatWidget(
            label: 'Risk exposure',
            value: 'Low',
            delta: 'Stable',
            color: AppColors.purple,
            icon: Icons.shield_rounded,
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
