import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/finance_models.dart';
import '../theme/app_colors.dart';

class NavigationItem {
  const NavigationItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class AuroraBackground extends StatefulWidget {
  const AuroraBackground({required this.child, super.key});

  final Widget child;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.auroraBackground),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = _controller.value * math.pi * 2;
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: -150 + math.sin(value) * 26,
                left: -100 + math.cos(value) * 38,
                child: const _GlowOrb(
                  size: 360,
                  color: AppColors.electricBlue,
                  opacity: 0.34,
                ),
              ),
              Positioned(
                top: 120 + math.cos(value * 0.7) * 46,
                right: -130 + math.sin(value * 0.9) * 30,
                child: const _GlowOrb(
                  size: 320,
                  color: AppColors.pink,
                  opacity: 0.28,
                ),
              ),
              Positioned(
                bottom: -170 + math.sin(value * 0.8) * 34,
                left: 60 + math.cos(value) * 28,
                child: const _GlowOrb(
                  size: 390,
                  color: AppColors.emerald,
                  opacity: 0.18,
                ),
              ),
              CustomPaint(painter: _ParticlePainter(_controller.value)),
              child!,
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter(this.phase);

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 18; i++) {
      final progress = (phase + i * 0.071) % 1;
      final x = size.width * ((i * 0.137 + progress * 0.18) % 1);
      final y = size.height * ((i * 0.233 + progress * 0.12) % 1);
      final radius = 1.4 + (i % 4) * 0.7;
      paint.color = Colors.white.withValues(alpha: 0.04 + (i % 3) * 0.02);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}

class AnimatedEntrance extends StatefulWidget {
  const AnimatedEntrance({
    required this.child,
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Duration delay;

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(curve);
    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

class GlassCard extends StatefulWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 32,
    this.gradient,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap != null && mounted) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: AppColors.electricBlue.withValues(alpha: 0.16),
                blurRadius: 34,
                offset: const Offset(0, 24),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 42,
                offset: const Offset(0, 22),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: widget.padding,
                decoration: BoxDecoration(
                  gradient:
                      widget.gradient ??
                      LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.18),
                          Colors.white.withValues(alpha: 0.06),
                        ],
                      ),
                  borderRadius: radius,
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: _pressed ? 0.34 : 0.18,
                    ),
                  ),
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatefulWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient = AppColors.neonGradient,
    this.expanded = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Gradient gradient;
  final bool expanded;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final child = AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 140),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.pink.withValues(alpha: 0.26),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: Colors.white),
                const SizedBox(width: 10),
              ],
              Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );

    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: widget.expanded
          ? SizedBox(width: double.infinity, child: child)
          : child,
    );
  }
}

class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
    this.style,
    super.key,
  });

  final double value;
  final String prefix;
  final String suffix;
  final int decimals;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutExpo,
      builder: (context, animatedValue, _) {
        return Text(
          '$prefix${_formatNumber(animatedValue, decimals)}$suffix',
          style: style ?? Theme.of(context).textTheme.headlineLarge,
        );
      },
    );
  }

  String _formatNumber(double number, int precision) {
    final parts = number.toStringAsFixed(precision).split('.');
    final integer = parts.first;
    final buffer = StringBuffer();
    for (var i = 0; i < integer.length; i++) {
      final indexFromEnd = integer.length - i;
      buffer.write(integer[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    if (parts.length == 1 || precision == 0) {
      return buffer.toString();
    }
    return '$buffer.${parts.last}';
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.action, super.key});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (action != null)
            Text(
              action!,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.cyan),
            ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    required this.color,
    this.icon,
    super.key,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class StatWidget extends StatelessWidget {
  const StatWidget({
    required this.label,
    required this.value,
    required this.delta,
    required this.color,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final String delta;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const Spacer(),
              StatusChip(label: delta, color: color),
            ],
          ),
          const SizedBox(height: 20),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class PremiumPaymentCard extends StatefulWidget {
  const PremiumPaymentCard({required this.card, super.key});

  final PremiumCardData card;

  @override
  State<PremiumPaymentCard> createState() => _PremiumPaymentCardState();
}

class _PremiumPaymentCardState extends State<PremiumPaymentCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final sweep = -1.0 + _controller.value * 2.8;
        return Container(
          height: 218,
          decoration: BoxDecoration(
            gradient: widget.card.gradient,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: widget.card.accent.withValues(alpha: 0.32),
                blurRadius: 36,
                offset: const Offset(0, 22),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Stack(
              children: [
                Positioned(
                  right: -54,
                  top: -38,
                  child: _OutlinedOrb(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                Positioned(
                  left: -70,
                  bottom: -90,
                  child: _OutlinedOrb(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                Align(
                  alignment: Alignment(sweep, -0.2),
                  child: Transform.rotate(
                    angle: -0.7,
                    child: Container(
                      width: 44,
                      height: 360,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.card.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.contactless_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        widget.card.number,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Text(
                            'Available',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.72),
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '\$${widget.card.balance.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OutlinedOrb extends StatelessWidget {
  const _OutlinedOrb({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 28),
      ),
    );
  }
}

class SpendingChart extends StatelessWidget {
  const SpendingChart({required this.points, this.height = 220, super.key});

  final List<ChartPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) {
        return SizedBox(
          height: height,
          child: CustomPaint(
            painter: _SpendingChartPainter(points: points, progress: progress),
            child: Align(
              alignment: Alignment.topLeft,
              child: StatusChip(
                label: 'Live spend intelligence',
                color: AppColors.cyan,
                icon: Icons.auto_graph_rounded,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SpendingChartPainter extends CustomPainter {
  const _SpendingChartPainter({required this.points, required this.progress});

  final List<ChartPoint> points;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), axisPaint);
    }

    final barWidth = size.width / (points.length * 2.2);
    final gap = barWidth * 1.2;
    final bottom = size.height - 24;
    final maxHeight = size.height - 66;

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final left = i * (barWidth + gap) + 14;
      final height = maxHeight * point.value * progress;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, bottom - height, barWidth, height),
        const Radius.circular(14),
      );
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [point.color, point.color.withValues(alpha: 0.16)],
        ).createShader(rect.outerRect);
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpendingChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.points != points;
  }
}

class InsightCard extends StatelessWidget {
  const InsightCard({required this.insight, super.key});

  final InsightData insight;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradient: insight.gradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(insight.icon, color: Colors.white),
              ),
              const Spacer(),
              Text(
                insight.value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(insight.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            insight.detail,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumTransactionTile extends StatelessWidget {
  const PremiumTransactionTile({required this.transaction, super.key});

  final TransactionData transaction;

  @override
  Widget build(BuildContext context) {
    final sign = transaction.isCredit ? '+' : '-';
    final color = transaction.isCredit
        ? AppColors.emerald
        : AppColors.textPrimary;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: transaction.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: transaction.color.withValues(alpha: 0.28),
              ),
            ),
            child: Icon(transaction.icon, color: transaction.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.merchant,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.category} • ${transaction.time}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '$sign\$${transaction.amount.toStringAsFixed(2)}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class PremiumBottomNav extends StatelessWidget {
  const PremiumBottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<NavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(8),
      borderRadius: 30,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _NavButton(
                item: items[i],
                selected: selectedIndex == i,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(22),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.electricBlue.withValues(alpha: 0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: selected ? Colors.white : AppColors.textSecondary,
              size: 22,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactAvatar extends StatelessWidget {
  const ContactAvatar({
    required this.contact,
    this.selected = false,
    super.key,
  });

  final ContactData contact;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: selected ? 64 : 58,
          height: selected ? 64 : 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [contact.color, AppColors.purple]),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: selected ? 0.72 : 0.18),
              width: selected ? 3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: contact.color.withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              contact.initials,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(contact.name, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class SuccessBurst extends StatefulWidget {
  const SuccessBurst({required this.active, super.key});

  final bool active;

  @override
  State<SuccessBurst> createState() => _SuccessBurstState();
}

class _SuccessBurstState extends State<SuccessBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(covariant SuccessBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _SuccessBurstPainter(_controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _SuccessBurstPainter extends CustomPainter {
  const _SuccessBurstPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) {
      return;
    }
    final center = Offset(size.width / 2, size.height / 2);
    final colors = [
      AppColors.cyan,
      AppColors.pink,
      AppColors.emerald,
      AppColors.orange,
      AppColors.purple,
    ];
    for (var i = 0; i < 28; i++) {
      final angle = (math.pi * 2 / 28) * i;
      final distance = 30 + progress * (110 + (i % 5) * 12);
      final opacity = (1 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: opacity)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      final start =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      final end = start + Offset(math.cos(angle), math.sin(angle)) * 12;
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SuccessBurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
