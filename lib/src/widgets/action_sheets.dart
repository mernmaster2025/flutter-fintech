import 'package:flutter/material.dart';

import '../domain/crypto_models.dart';
import '../state/app_controller.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'premium_components.dart';

Future<void> showOrderSheet(
  BuildContext context, {
  required OrderSide side,
  String? initialAssetId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final controller = AppScope.watch(context);
      var assetId = initialAssetId ?? controller.assets.first.id;
      final amountController = TextEditingController(
        text: side == OrderSide.buy ? '500' : '250',
      );
      return _PremiumSheet(
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            final asset = controller.assetFor(assetId);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: side == OrderSide.buy ? 'Buy crypto' : 'Sell crypto',
                  action: asset.symbol,
                ),
                DropdownButtonFormField<String>(
                  initialValue: assetId,
                  decoration: const InputDecoration(labelText: 'Asset'),
                  dropdownColor: AppColors.ink,
                  items: [
                    for (final asset in controller.assets)
                      DropdownMenuItem(
                        value: asset.id,
                        child: Text('${asset.symbol} • ${asset.name}'),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setSheetState(() => assetId = value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'USD amount',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 24,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Market price',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        money(asset.price),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                GradientButton(
                  label: controller.busy
                      ? 'Processing...'
                      : side == OrderSide.buy
                      ? 'Preview buy'
                      : 'Preview sell',
                  icon: side == OrderSide.buy
                      ? Icons.add_chart_rounded
                      : Icons.trending_down_rounded,
                  expanded: true,
                  gradient: side == OrderSide.buy
                      ? AppColors.successGradient
                      : AppColors.warmGradient,
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    final app = AppScope.read(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    final success = await app.placeOrder(
                      assetId: assetId,
                      side: side,
                      usdAmount: amount,
                    );
                    final message = app.message;
                    if (success) {
                      navigator.pop();
                    }
                    if (message != null) {
                      messenger.showSnackBar(SnackBar(content: Text(message)));
                    }
                  },
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

Future<void> showTransferSheet(
  BuildContext context, {
  TransferType? initialType,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final controller = AppScope.watch(context);
      var type = initialType ?? TransferType.send;
      var recipientId = controller.recipients.first.id;
      final amountController = TextEditingController(text: '250');
      final noteController = TextEditingController();
      return _PremiumSheet(
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Move money', action: 'USD rail'),
                DropdownButtonFormField<TransferType>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Transfer type'),
                  dropdownColor: AppColors.ink,
                  items: const [
                    DropdownMenuItem(
                      value: TransferType.send,
                      child: Text('Send'),
                    ),
                    DropdownMenuItem(
                      value: TransferType.deposit,
                      child: Text('Deposit'),
                    ),
                    DropdownMenuItem(
                      value: TransferType.withdraw,
                      child: Text('Withdraw'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setSheetState(() => type = value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: recipientId,
                  decoration: const InputDecoration(
                    labelText: 'Recipient / rail',
                  ),
                  dropdownColor: AppColors.ink,
                  items: [
                    for (final recipient in controller.recipients)
                      DropdownMenuItem(
                        value: recipient.id,
                        child: Text('${recipient.name} • ${recipient.network}'),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setSheetState(() => recipientId = value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'USD amount',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    prefixIcon: Icon(Icons.edit_note_rounded),
                  ),
                ),
                const SizedBox(height: 18),
                GradientButton(
                  label: controller.busy ? 'Submitting...' : 'Submit transfer',
                  icon: Icons.near_me_rounded,
                  expanded: true,
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    final app = AppScope.read(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    final success = await app.submitTransfer(
                      type: type,
                      recipientId: recipientId,
                      amount: amount,
                      note: noteController.text,
                    );
                    final message = app.message;
                    if (success) {
                      navigator.pop();
                    }
                    if (message != null) {
                      messenger.showSnackBar(SnackBar(content: Text(message)));
                    }
                  },
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

Future<void> showAssetDetailSheet(BuildContext context, CryptoAsset asset) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final controller = AppScope.watch(context);
      final holding = controller.holdingFor(asset.id);
      final isWatched = controller.snapshot.watchlistIds.contains(asset.id);
      return _PremiumSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 24,
              child: Column(
                children: [
                  _MetricRow(
                    label: 'Market cap',
                    value: compactMoney(asset.marketCap),
                  ),
                  _MetricRow(
                    label: 'Your position',
                    value: holding == null
                        ? 'No position'
                        : '${holding.quantity.toStringAsFixed(5)} ${asset.symbol}',
                  ),
                  _MetricRow(
                    label: 'Position value',
                    value: money(controller.holdingValue(asset.id)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    label: 'Buy',
                    icon: Icons.add_chart_rounded,
                    gradient: AppColors.successGradient,
                    onPressed: () {
                      Navigator.of(context).pop();
                      showOrderSheet(
                        context,
                        side: OrderSide.buy,
                        initialAssetId: asset.id,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    label: 'Sell',
                    icon: Icons.trending_down_rounded,
                    gradient: AppColors.warmGradient,
                    onPressed: () {
                      Navigator.of(context).pop();
                      showOrderSheet(
                        context,
                        side: OrderSide.sell,
                        initialAssetId: asset.id,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GradientButton(
              label: isWatched ? 'Remove from watchlist' : 'Add to watchlist',
              icon: isWatched ? Icons.star_rounded : Icons.star_border_rounded,
              expanded: true,
              gradient: AppColors.primaryGradient,
              onPressed: () async {
                final app = AppScope.read(context);
                final messenger = ScaffoldMessenger.of(context);
                await app.toggleWatchlist(asset.id);
                final message = app.message;
                if (message != null) {
                  messenger.showSnackBar(SnackBar(content: Text(message)));
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showReportSheet(BuildContext context) {
  final report = AppScope.read(context).generateReport();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _PremiumSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Generated report',
              action: 'Mock export',
            ),
            SelectableText(
              report,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            GradientButton(
              label: 'Done',
              icon: Icons.check_rounded,
              expanded: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    },
  );
}

class _PremiumSheet extends StatelessWidget {
  const _PremiumSheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: GlassCard(padding: const EdgeInsets.all(22), child: child),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
