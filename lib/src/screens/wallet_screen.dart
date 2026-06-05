import 'package:flutter/material.dart';

import '../domain/crypto_models.dart';
import '../models/finance_models.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/action_sheets.dart';
import '../widgets/premium_components.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedAsset = 0;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.watch(context);
    final selectedIndex = _selectedAsset
        .clamp(0, controller.assets.length - 1)
        .toInt();
    final selectedAsset = controller.assets[selectedIndex];
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
                  AnimatedEntrance(
                    child: _WalletHeader(controller: controller),
                  ),
                  const SizedBox(height: 22),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _AssetShowcase(
                            controller: controller,
                            asset: selectedAsset,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _AssetControls(
                            controller: controller,
                            selectedAsset: _selectedAsset,
                            onSelected: (index) {
                              setState(() => _selectedAsset = index);
                            },
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _AssetShowcase(
                      controller: controller,
                      asset: selectedAsset,
                    ),
                    const SizedBox(height: 20),
                    _AssetControls(
                      controller: controller,
                      selectedAsset: _selectedAsset,
                      onSelected: (index) {
                        setState(() => _selectedAsset = index);
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
  const _WalletHeader({required this.controller});

  final AppController controller;

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
                  label: 'Crypto wallet',
                  color: AppColors.emerald,
                  icon: Icons.account_balance_wallet_rounded,
                ),
                const SizedBox(height: 18),
                Text(
                  'Holdings, watchlist, and spend controls now persist.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  '${controller.holdings.length} positions • ${controller.watchlist.length} watched • ${controller.orders.length} executed orders',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          const Icon(
            Icons.currency_bitcoin_rounded,
            color: AppColors.cyan,
            size: 70,
          ),
        ],
      ),
    );
  }
}

class _AssetShowcase extends StatelessWidget {
  const _AssetShowcase({required this.controller, required this.asset});

  final AppController controller;
  final CryptoAsset asset;

  @override
  Widget build(BuildContext context) {
    final holding = controller.holdingFor(asset.id);
    final watched = controller.snapshot.watchlistIds.contains(asset.id);
    return Column(
      children: [
        Hero(
          tag: 'wallet-${asset.id}',
          child: Material(
            color: Colors.transparent,
            child: PremiumPaymentCard(
              card: PremiumCardData(
                name: '${asset.name} Reserve',
                number: '${asset.symbol}  ••••  ${asset.id.toUpperCase()}',
                balance: controller.holdingValue(asset.id),
                gradient: _assetGradient(asset.id),
                accent: _assetColor(asset.id),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: asset.name, action: asset.symbol),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      money(asset.price),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  StatusChip(
                    label: percent(asset.change24h),
                    color: asset.change24h >= 0
                        ? AppColors.emerald
                        : AppColors.pink,
                    icon: asset.change24h >= 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                holding == null
                    ? 'No position yet. Buy ${asset.symbol} to start tracking realized execution history.'
                    : '${holding.quantity.toStringAsFixed(6)} ${asset.symbol} held at ${money(holding.averageCost)} average cost.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  GradientButton(
                    label: 'Buy',
                    icon: Icons.add_chart_rounded,
                    gradient: AppColors.successGradient,
                    onPressed: () => showOrderSheet(
                      context,
                      side: OrderSide.buy,
                      initialAssetId: asset.id,
                    ),
                  ),
                  GradientButton(
                    label: 'Sell',
                    icon: Icons.trending_down_rounded,
                    gradient: AppColors.warmGradient,
                    onPressed: () => showOrderSheet(
                      context,
                      side: OrderSide.sell,
                      initialAssetId: asset.id,
                    ),
                  ),
                  GradientButton(
                    label: watched ? 'Watching' : 'Watch',
                    icon: watched
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    gradient: AppColors.primaryGradient,
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await controller.toggleWatchlist(asset.id);
                      if (controller.message != null) {
                        messenger.showSnackBar(
                          SnackBar(content: Text(controller.message!)),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AssetControls extends StatelessWidget {
  const _AssetControls({
    required this.controller,
    required this.selectedAsset,
    required this.onSelected,
  });

  final AppController controller;
  final int selectedAsset;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Assets', action: 'Tap to inspect'),
              for (var i = 0; i < controller.assets.length; i++) ...[
                _AssetSelector(
                  controller: controller,
                  asset: controller.assets[i],
                  selected: selectedAsset == i,
                  onTap: () => onSelected(i),
                ),
                if (i != controller.assets.length - 1)
                  const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        _SecurityControls(controller: controller),
      ],
    );
  }
}

class _AssetSelector extends StatelessWidget {
  const _AssetSelector({
    required this.controller,
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  final AppController controller;
  final CryptoAsset asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final holdingValue = controller.holdingValue(asset.id);
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 22,
      onTap: onTap,
      gradient: selected
          ? LinearGradient(
              colors: [
                _assetColor(asset.id).withValues(alpha: 0.32),
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
              gradient: _assetGradient(asset.id),
              borderRadius: BorderRadius.circular(12),
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
                  '${asset.symbol} • ${money(asset.price)} • ${compactMoney(holdingValue)} held',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => showAssetDetailSheet(context, asset),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _SecurityControls extends StatelessWidget {
  const _SecurityControls({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final controls = controller.cardControls;
    final rows = [
      (
        Icons.lock_rounded,
        'Freeze instantly',
        AppColors.cyan,
        controls.frozen,
        (bool value) => controls.copyWith(frozen: value),
      ),
      (
        Icons.radar_rounded,
        'Merchant radar',
        AppColors.pink,
        controls.merchantRadar,
        (bool value) => controls.copyWith(merchantRadar: value),
      ),
      (
        Icons.travel_explore_rounded,
        'Travel mode',
        AppColors.orange,
        controls.travelMode,
        (bool value) => controls.copyWith(travelMode: value),
      ),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Card controls'),
          for (final row in rows) ...[
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: row.$3.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(row.$1, color: row.$3),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    row.$2,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch.adaptive(
                  value: row.$4,
                  activeThumbColor: AppColors.emerald,
                  onChanged: (value) async {
                    final messenger = ScaffoldMessenger.of(context);
                    await controller.updateCardControls(row.$5(value));
                    if (controller.message != null) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(controller.message!)),
                      );
                    }
                  },
                ),
              ],
            ),
            if (row != rows.last) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

Gradient _assetGradient(String assetId) {
  return switch (assetId) {
    'btc' => AppColors.warmGradient,
    'eth' => AppColors.neonGradient,
    'sol' => AppColors.cardGradient,
    'link' => AppColors.successGradient,
    _ => AppColors.primaryGradient,
  };
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
