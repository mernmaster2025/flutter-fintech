import 'package:flutter/material.dart';

import '../domain/crypto_models.dart';
import '../theme/app_colors.dart';

String money(double value, {int decimals = 2}) {
  final sign = value < 0 ? '-' : '';
  final absolute = value.abs().toStringAsFixed(decimals);
  final parts = absolute.split('.');
  final integer = parts.first;
  final buffer = StringBuffer(sign);
  for (var i = 0; i < integer.length; i++) {
    final indexFromEnd = integer.length - i;
    buffer.write(integer[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
      buffer.write(',');
    }
  }
  if (decimals == 0) {
    return '\$$buffer';
  }
  return '\$$buffer.${parts.last}';
}

String signedMoney(double value) {
  final prefix = value >= 0 ? '+' : '-';
  return '$prefix${money(value.abs())}';
}

String percent(double value) {
  final prefix = value >= 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(2)}%';
}

String compactMoney(double value) {
  final absolute = value.abs();
  if (absolute >= 1000000000000) {
    return '\$${(value / 1000000000000).toStringAsFixed(2)}T';
  }
  if (absolute >= 1000000000) {
    return '\$${(value / 1000000000).toStringAsFixed(2)}B';
  }
  if (absolute >= 1000000) {
    return '\$${(value / 1000000).toStringAsFixed(2)}M';
  }
  if (absolute >= 1000) {
    return '\$${(value / 1000).toStringAsFixed(1)}k';
  }
  return money(value);
}

String relativeTime(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) {
    return 'Now';
  }
  if (diff.inHours < 1) {
    return '${diff.inMinutes}m';
  }
  if (diff.inDays < 1) {
    return '${diff.inHours}h';
  }
  return '${diff.inDays}d';
}

IconData activityIcon(ActivityType type) {
  return switch (type) {
    ActivityType.trade => Icons.candlestick_chart_rounded,
    ActivityType.transfer => Icons.near_me_rounded,
    ActivityType.card => Icons.credit_card_rounded,
    ActivityType.alert => Icons.notifications_active_rounded,
    ActivityType.system => Icons.auto_awesome_rounded,
  };
}

Color activityColor(ActivityType type) {
  return switch (type) {
    ActivityType.trade => AppColors.purple,
    ActivityType.transfer => AppColors.cyan,
    ActivityType.card => AppColors.orange,
    ActivityType.alert => AppColors.pink,
    ActivityType.system => AppColors.emerald,
  };
}
