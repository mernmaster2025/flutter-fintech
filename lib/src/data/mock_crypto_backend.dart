import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/crypto_models.dart';
import 'repositories.dart';

class MockCryptoBackend
    implements
        MarketRepository,
        PortfolioRepository,
        OrderRepository,
        TransferRepository,
        ProfileRepository,
        CardRepository {
  MockCryptoBackend();

  static const _storageKey = 'astra_crypto_snapshot_v1';

  final _random = math.Random(8);
  StreamController<List<CryptoAsset>>? _marketController;
  Timer? _marketTimer;

  SharedPreferences? _prefs;
  CryptoAppSnapshot? _snapshot;

  Future<SharedPreferences> get _store async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<CryptoAppSnapshot> loadSnapshot() async {
    await _simulateLatency();
    final store = await _store;
    final raw = store.getString(_storageKey);
    if (raw == null) {
      _snapshot = _seedSnapshot();
      await saveSnapshot(_snapshot!);
      return _snapshot!;
    }

    try {
      _snapshot = CryptoAppSnapshot.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      return _snapshot!;
    } catch (_) {
      _snapshot = _seedSnapshot();
      await saveSnapshot(_snapshot!);
      return _snapshot!;
    }
  }

  @override
  Future<CryptoAppSnapshot> saveSnapshot(CryptoAppSnapshot snapshot) async {
    _snapshot = snapshot;
    final store = await _store;
    await store.setString(_storageKey, jsonEncode(snapshot.toJson()));
    return snapshot;
  }

  @override
  Future<List<CryptoAsset>> refreshMarkets() async {
    await _simulateLatency(milliseconds: 520);
    final snapshot = _snapshot ?? await loadSnapshot();
    final updated = _tickAssets(snapshot.assets, multiplier: 1.8);
    await saveSnapshot(snapshot.copyWith(assets: updated));
    return updated;
  }

  @override
  Stream<List<CryptoAsset>> watchMarketTicks() {
    _marketController ??= StreamController<List<CryptoAsset>>.broadcast(
      onListen: _startMarketTicks,
      onCancel: () {
        if (!(_marketController?.hasListener ?? false)) {
          _marketTimer?.cancel();
          _marketTimer = null;
        }
      },
    );
    return _marketController!.stream;
  }

  void _startMarketTicks() {
    _emitTick();
    _marketTimer ??= Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_marketController == null || _marketController!.isClosed) {
        timer.cancel();
        _marketTimer = null;
        return;
      }
      _emitTick();
    });
  }

  Future<void> _emitTick() async {
    final snapshot = _snapshot ?? await loadSnapshot();
    final updated = _tickAssets(snapshot.assets);
    await saveSnapshot(snapshot.copyWith(assets: updated));
    if (!(_marketController?.isClosed ?? true)) {
      _marketController?.add(updated);
    }
  }

  @override
  Future<CryptoAppSnapshot> placeOrder({
    required CryptoAppSnapshot snapshot,
    required String assetId,
    required OrderSide side,
    required double usdAmount,
  }) async {
    await _simulateLatency(milliseconds: 680);
    if (usdAmount <= 0) {
      throw const CryptoBackendException(r'Enter an amount greater than $0.');
    }

    final asset = snapshot.assets.firstWhere((item) => item.id == assetId);
    final existingHolding = snapshot.holdings
        .where((holding) => holding.assetId == assetId)
        .firstOrNull;
    final quantity = usdAmount / asset.price;

    if (side == OrderSide.buy && snapshot.cashBalance < usdAmount) {
      throw const CryptoBackendException('Insufficient USD balance.');
    }

    if (side == OrderSide.sell) {
      final ownedValue = (existingHolding?.quantity ?? 0) * asset.price;
      if (ownedValue < usdAmount) {
        throw CryptoBackendException('Insufficient ${asset.symbol} balance.');
      }
    }

    final updatedHoldings = [...snapshot.holdings];
    final holdingIndex = updatedHoldings.indexWhere(
      (holding) => holding.assetId == assetId,
    );
    if (side == OrderSide.buy) {
      if (holdingIndex == -1) {
        updatedHoldings.add(
          Holding(
            assetId: assetId,
            quantity: quantity,
            averageCost: asset.price,
          ),
        );
      } else {
        final holding = updatedHoldings[holdingIndex];
        final currentCost = holding.quantity * holding.averageCost;
        final newQuantity = holding.quantity + quantity;
        updatedHoldings[holdingIndex] = holding.copyWith(
          quantity: newQuantity,
          averageCost: (currentCost + usdAmount) / newQuantity,
        );
      }
    } else {
      final holding = updatedHoldings[holdingIndex];
      final newQuantity = holding.quantity - quantity;
      if (newQuantity <= 0.00000001) {
        updatedHoldings.removeAt(holdingIndex);
      } else {
        updatedHoldings[holdingIndex] = holding.copyWith(quantity: newQuantity);
      }
    }

    final order = TradeOrder(
      id: _id('ord'),
      assetId: assetId,
      side: side,
      usdAmount: usdAmount,
      assetQuantity: quantity,
      executionPrice: asset.price,
      createdAt: DateTime.now(),
      status: 'Filled',
    );

    final activity = ActivityEvent(
      id: _id('act'),
      type: ActivityType.trade,
      title: '${side == OrderSide.buy ? 'Bought' : 'Sold'} ${asset.symbol}',
      subtitle:
          '${quantity.toStringAsFixed(6)} ${asset.symbol} at \$${asset.price.toStringAsFixed(2)}',
      amount: side == OrderSide.buy ? -usdAmount : usdAmount,
      createdAt: order.createdAt,
    );

    final updated = snapshot.copyWith(
      cashBalance: side == OrderSide.buy
          ? snapshot.cashBalance - usdAmount
          : snapshot.cashBalance + usdAmount,
      holdings: updatedHoldings,
      orders: [order, ...snapshot.orders],
      activities: [activity, ...snapshot.activities],
    );
    return saveSnapshot(updated);
  }

  @override
  Future<CryptoAppSnapshot> submitTransfer({
    required CryptoAppSnapshot snapshot,
    required TransferType type,
    required String recipientId,
    required double amount,
    required String note,
  }) async {
    await _simulateLatency(milliseconds: 620);
    if (amount <= 0) {
      throw const CryptoBackendException('Enter a transfer amount.');
    }

    final double fee = switch (type) {
      TransferType.deposit => 0,
      TransferType.withdraw => math.max(1.25, amount * 0.0015),
      TransferType.send => math.max(0.75, amount * 0.001),
    };
    final debit = type == TransferType.deposit ? 0 : amount + fee;
    if (snapshot.cashBalance < debit) {
      throw const CryptoBackendException('Insufficient USD balance.');
    }

    final recipient = snapshot.recipients.firstWhere(
      (item) => item.id == recipientId,
      orElse: () => snapshot.recipients.first,
    );
    final transfer = TransferRecord(
      id: _id('trn'),
      type: type,
      recipientId: recipientId,
      amount: amount,
      fee: fee,
      note: note.trim(),
      createdAt: DateTime.now(),
      status: 'Completed',
    );
    final direction = type == TransferType.deposit ? 1 : -1;
    final activity = ActivityEvent(
      id: _id('act'),
      type: ActivityType.transfer,
      title: switch (type) {
        TransferType.deposit => 'Deposited USD',
        TransferType.withdraw => 'Withdrew USD',
        TransferType.send => 'Sent to ${recipient.name}',
      },
      subtitle: note.trim().isEmpty ? '${recipient.network} rail' : note.trim(),
      amount: direction * amount,
      createdAt: transfer.createdAt,
    );

    final updated = snapshot.copyWith(
      cashBalance: snapshot.cashBalance + direction * amount - fee,
      transfers: [transfer, ...snapshot.transfers],
      activities: [activity, ...snapshot.activities],
    );
    return saveSnapshot(updated);
  }

  @override
  Future<CryptoAppSnapshot> updateControls({
    required CryptoAppSnapshot snapshot,
    required CardControls controls,
  }) async {
    await _simulateLatency(milliseconds: 260);
    final activity = ActivityEvent(
      id: _id('act'),
      type: ActivityType.card,
      title: 'Card controls updated',
      subtitle: controls.frozen ? 'Card frozen instantly' : 'Card active',
      amount: 0,
      createdAt: DateTime.now(),
    );
    return saveSnapshot(
      snapshot.copyWith(
        cardControls: controls,
        activities: [activity, ...snapshot.activities],
      ),
    );
  }

  @override
  Future<CryptoAppSnapshot> updateSettings({
    required CryptoAppSnapshot snapshot,
    required UserSettings settings,
  }) async {
    await _simulateLatency(milliseconds: 240);
    return saveSnapshot(snapshot.copyWith(settings: settings));
  }

  List<CryptoAsset> _tickAssets(
    List<CryptoAsset> assets, {
    double multiplier = 1,
  }) {
    return [
      for (final asset in assets)
        () {
          final move = (_random.nextDouble() - 0.46) * 0.018 * multiplier;
          final price = (asset.price * (1 + move)).clamp(0.01, double.infinity);
          final nextSparkline = [...asset.sparkline.skip(1), price.toDouble()];
          return asset.copyWith(
            price: price.toDouble(),
            change24h: asset.change24h + move * 100,
            sparkline: nextSparkline,
          );
        }(),
    ];
  }

  Future<void> _simulateLatency({int milliseconds = 380}) {
    return Future<void>.delayed(Duration(milliseconds: milliseconds));
  }

  String _id(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(9999)}';
  }

  CryptoAppSnapshot _seedSnapshot() {
    final now = DateTime.now();
    return CryptoAppSnapshot(
      cashBalance: 18420.75,
      assets: const [
        CryptoAsset(
          id: 'btc',
          symbol: 'BTC',
          name: 'Bitcoin',
          price: 104820.42,
          change24h: 3.4,
          marketCap: 2060000000000,
          sparkline: [99000, 100400, 100180, 102200, 103400, 104820],
        ),
        CryptoAsset(
          id: 'eth',
          symbol: 'ETH',
          name: 'Ethereum',
          price: 3850.12,
          change24h: 4.8,
          marketCap: 462000000000,
          sparkline: [3440, 3500, 3610, 3680, 3775, 3850],
        ),
        CryptoAsset(
          id: 'sol',
          symbol: 'SOL',
          name: 'Solana',
          price: 192.38,
          change24h: 7.1,
          marketCap: 91000000000,
          sparkline: [168, 174, 181, 178, 187, 192],
        ),
        CryptoAsset(
          id: 'link',
          symbol: 'LINK',
          name: 'Chainlink',
          price: 18.62,
          change24h: -1.2,
          marketCap: 12000000000,
          sparkline: [19.2, 19.0, 18.4, 18.7, 18.5, 18.62],
        ),
      ],
      holdings: const [
        Holding(assetId: 'btc', quantity: 0.54, averageCost: 69400),
        Holding(assetId: 'eth', quantity: 8.2, averageCost: 2460),
        Holding(assetId: 'sol', quantity: 126, averageCost: 94),
      ],
      orders: const [],
      transfers: const [],
      recipients: const [
        Recipient(
          id: 'maya',
          name: 'Maya',
          initials: 'MK',
          walletAddress: '0xA12...9F4',
          network: 'Ethereum',
        ),
        Recipient(
          id: 'noah',
          name: 'Noah',
          initials: 'NL',
          walletAddress: 'bc1q...8dp',
          network: 'Bitcoin',
        ),
        Recipient(
          id: 'ava',
          name: 'Ava',
          initials: 'AR',
          walletAddress: '7xK...p91',
          network: 'Solana',
        ),
        Recipient(
          id: 'theo',
          name: 'Theo',
          initials: 'TW',
          walletAddress: '0x44...a7C',
          network: 'Base',
        ),
      ],
      activities: [
        ActivityEvent(
          id: 'act-seed-1',
          type: ActivityType.trade,
          title: 'Bought SOL',
          subtitle: '126 SOL at \$94.00',
          amount: -11844,
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
        ActivityEvent(
          id: 'act-seed-2',
          type: ActivityType.transfer,
          title: 'Deposited USD',
          subtitle: 'ACH completed',
          amount: 25000,
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        ActivityEvent(
          id: 'act-seed-3',
          type: ActivityType.alert,
          title: 'BTC alert triggered',
          subtitle: 'Crossed \$104k target',
          amount: 0,
          createdAt: now.subtract(const Duration(days: 2)),
        ),
      ],
      watchlistIds: const {'btc', 'eth', 'sol'},
      cardControls: const CardControls(
        frozen: false,
        merchantRadar: true,
        travelMode: false,
      ),
      settings: const UserSettings(
        smartAlerts: true,
        biometricApprovals: true,
        dynamicTheme: true,
        concierge: true,
      ),
      profile: const UserProfile(
        name: 'Alex Morgan',
        email: 'alex@astra.finance',
        plan: 'Astra Infinite',
        verified: true,
      ),
    );
  }
}

class CryptoBackendException implements Exception {
  const CryptoBackendException(this.message);

  final String message;

  @override
  String toString() => message;
}

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
