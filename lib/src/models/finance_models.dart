import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AccountSnapshot {
  const AccountSnapshot({
    required this.balance,
    required this.delta,
    required this.cashback,
    required this.savingsRate,
  });

  final double balance;
  final double delta;
  final double cashback;
  final double savingsRate;
}

class PremiumCardData {
  const PremiumCardData({
    required this.name,
    required this.number,
    required this.balance,
    required this.gradient,
    required this.accent,
  });

  final String name;
  final String number;
  final double balance;
  final Gradient gradient;
  final Color accent;
}

class TransactionData {
  const TransactionData({
    required this.merchant,
    required this.category,
    required this.amount,
    required this.time,
    required this.icon,
    required this.color,
    this.isCredit = false,
  });

  final String merchant;
  final String category;
  final double amount;
  final String time;
  final IconData icon;
  final Color color;
  final bool isCredit;
}

class InsightData {
  const InsightData({
    required this.title,
    required this.detail,
    required this.value,
    required this.gradient,
    required this.icon,
  });

  final String title;
  final String detail;
  final String value;
  final Gradient gradient;
  final IconData icon;
}

class ChartPoint {
  const ChartPoint(this.label, this.value, this.color);

  final String label;
  final double value;
  final Color color;
}

class ContactData {
  const ContactData({
    required this.name,
    required this.initials,
    required this.color,
  });

  final String name;
  final String initials;
  final Color color;
}

const accountSnapshot = AccountSnapshot(
  balance: 128430.72,
  delta: 18.4,
  cashback: 1420.35,
  savingsRate: 41.8,
);

const premiumCards = [
  PremiumCardData(
    name: 'Aurora Black',
    number: '4815  ••••  ••••  9201',
    balance: 84200,
    gradient: AppColors.cardGradient,
    accent: AppColors.pink,
  ),
  PremiumCardData(
    name: 'Neon Treasury',
    number: '5589  ••••  ••••  1174',
    balance: 32680,
    gradient: AppColors.successGradient,
    accent: AppColors.emerald,
  ),
  PremiumCardData(
    name: 'Founder Reserve',
    number: '6209  ••••  ••••  4318',
    balance: 11550,
    gradient: AppColors.warmGradient,
    accent: AppColors.orange,
  ),
];

const transactions = [
  TransactionData(
    merchant: 'Linear',
    category: 'SaaS tools',
    amount: 84.00,
    time: '09:42',
    icon: Icons.auto_awesome_rounded,
    color: AppColors.purple,
  ),
  TransactionData(
    merchant: 'Stripe Payout',
    category: 'Revenue',
    amount: 12840.92,
    time: 'Yesterday',
    icon: Icons.trending_up_rounded,
    color: AppColors.emerald,
    isCredit: true,
  ),
  TransactionData(
    merchant: 'Apple',
    category: 'Hardware',
    amount: 2499.00,
    time: 'Mon',
    icon: Icons.laptop_mac_rounded,
    color: AppColors.cyan,
  ),
  TransactionData(
    merchant: 'Ramp',
    category: 'Corporate card',
    amount: 318.21,
    time: 'Sun',
    icon: Icons.credit_card_rounded,
    color: AppColors.orange,
  ),
];

const insights = [
  InsightData(
    title: 'AI cash runway',
    detail:
        'Your projected runway increased by 7.5 months after lower cloud spend.',
    value: '26 mo',
    gradient: AppColors.primaryGradient,
    icon: Icons.psychology_alt_rounded,
  ),
  InsightData(
    title: 'Smart sweep',
    detail:
        r'Move idle cash into treasury reserves for an estimated $4.8k yield.',
    value: '+4.8k',
    gradient: AppColors.successGradient,
    icon: Icons.bolt_rounded,
  ),
];

const spendingBreakdown = [
  ChartPoint('SaaS', 0.72, AppColors.purple),
  ChartPoint('Travel', 0.52, AppColors.cyan),
  ChartPoint('Payroll', 0.86, AppColors.emerald),
  ChartPoint('Cloud', 0.64, AppColors.orange),
  ChartPoint('Ops', 0.38, AppColors.pink),
];

const contacts = [
  ContactData(name: 'Maya', initials: 'MK', color: AppColors.pink),
  ContactData(name: 'Noah', initials: 'NL', color: AppColors.cyan),
  ContactData(name: 'Ava', initials: 'AR', color: AppColors.emerald),
  ContactData(name: 'Theo', initials: 'TW', color: AppColors.orange),
];
