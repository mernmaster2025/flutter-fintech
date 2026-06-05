import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/mock_crypto_backend.dart';
import '../data/repositories.dart';
import '../domain/crypto_models.dart';

class AppController extends ChangeNotifier {
  AppController({
    required MarketRepository marketRepository,
    required PortfolioRepository portfolioRepository,
    required OrderRepository orderRepository,
    required TransferRepository transferRepository,
    required ProfileRepository profileRepository,
    required CardRepository cardRepository,
  }) : this._(
         marketRepository: marketRepository,
         portfolioRepository: portfolioRepository,
         orderRepository: orderRepository,
         transferRepository: transferRepository,
         profileRepository: profileRepository,
         cardRepository: cardRepository,
       );

  AppController._({
    required this._marketRepository,
    required this._portfolioRepository,
    required this._orderRepository,
    required this._transferRepository,
    required this._profileRepository,
    required this._cardRepository,
  });

  factory AppController.mock() {
    final backend = MockCryptoBackend();
    return AppController(
      marketRepository: backend,
      portfolioRepository: backend,
      orderRepository: backend,
      transferRepository: backend,
      profileRepository: backend,
      cardRepository: backend,
    );
  }

  final MarketRepository _marketRepository;
  final PortfolioRepository _portfolioRepository;
  final OrderRepository _orderRepository;
  final TransferRepository _transferRepository;
  final ProfileRepository _profileRepository;
  final CardRepository _cardRepository;

  CryptoAppSnapshot? _snapshot;
  StreamSubscription<List<CryptoAsset>>? _marketSubscription;
  bool _loading = true;
  bool _busy = false;
  String? _message;

  bool get loading => _loading;
  bool get busy => _busy;
  String? get message => _message;
  CryptoAppSnapshot get snapshot => _snapshot!;

  List<CryptoAsset> get assets => snapshot.assets;
  List<Holding> get holdings => snapshot.holdings;
  List<TradeOrder> get orders => snapshot.orders;
  List<TransferRecord> get transfers => snapshot.transfers;
  List<ActivityEvent> get activities => snapshot.activities;
  List<Recipient> get recipients => snapshot.recipients;
  UserProfile get profile => snapshot.profile;
  UserSettings get settings => snapshot.settings;
  CardControls get cardControls => snapshot.cardControls;
  double get cashBalance => snapshot.cashBalance;

  double get cryptoValue => holdings.fold(0, (total, holding) {
    return total + holding.quantity * assetFor(holding.assetId).price;
  });

  double get investedCost => holdings.fold(0, (total, holding) {
    return total + holding.quantity * holding.averageCost;
  });

  double get portfolioValue => cashBalance + cryptoValue;
  double get unrealizedPnL => cryptoValue - investedCost;
  double get unrealizedPnLPercent =>
      investedCost == 0 ? 0 : (unrealizedPnL / investedCost) * 100;
  double get dailyChangeUsd => holdings.fold(0, (total, holding) {
    final asset = assetFor(holding.assetId);
    return total + holding.quantity * asset.price * (asset.change24h / 100);
  });
  double get dailyChangePercent =>
      cryptoValue == 0 ? 0 : (dailyChangeUsd / cryptoValue) * 100;

  List<CryptoAsset> get watchlist => [
    for (final asset in assets)
      if (snapshot.watchlistIds.contains(asset.id)) asset,
  ];

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();
    _snapshot = await _portfolioRepository.loadSnapshot();
    _marketSubscription = _marketRepository.watchMarketTicks().listen((assets) {
      _snapshot = snapshot.copyWith(assets: assets);
      notifyListeners();
    });
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _marketSubscription?.cancel();
    super.dispose();
  }

  CryptoAsset assetFor(String assetId) {
    return assets.firstWhere((asset) => asset.id == assetId);
  }

  Holding? holdingFor(String assetId) {
    for (final holding in holdings) {
      if (holding.assetId == assetId) {
        return holding;
      }
    }
    return null;
  }

  double holdingValue(String assetId) {
    final holding = holdingFor(assetId);
    if (holding == null) {
      return 0;
    }
    return holding.quantity * assetFor(assetId).price;
  }

  Future<void> refresh() async {
    await _run(() async {
      final assets = await _marketRepository.refreshMarkets();
      _snapshot = snapshot.copyWith(assets: assets);
      _message = 'Markets refreshed with latest mock backend prices.';
    });
  }

  Future<bool> placeOrder({
    required String assetId,
    required OrderSide side,
    required double usdAmount,
  }) async {
    return _run(() async {
      _snapshot = await _orderRepository.placeOrder(
        snapshot: snapshot,
        assetId: assetId,
        side: side,
        usdAmount: usdAmount,
      );
      final asset = assetFor(assetId);
      _message = '${side == OrderSide.buy ? 'Bought' : 'Sold'} ${asset.symbol}';
    });
  }

  Future<bool> submitTransfer({
    required TransferType type,
    required String recipientId,
    required double amount,
    required String note,
  }) async {
    return _run(() async {
      _snapshot = await _transferRepository.submitTransfer(
        snapshot: snapshot,
        type: type,
        recipientId: recipientId,
        amount: amount,
        note: note,
      );
      _message = switch (type) {
        TransferType.deposit => 'Deposit completed',
        TransferType.withdraw => 'Withdrawal completed',
        TransferType.send => 'Transfer sent',
      };
    });
  }

  Future<void> toggleWatchlist(String assetId) async {
    final watchlist = {...snapshot.watchlistIds};
    if (!watchlist.add(assetId)) {
      watchlist.remove(assetId);
    }
    _snapshot = await _portfolioRepository.saveSnapshot(
      snapshot.copyWith(watchlistIds: watchlist),
    );
    _message = watchlist.contains(assetId)
        ? '${assetFor(assetId).symbol} added to watchlist'
        : '${assetFor(assetId).symbol} removed from watchlist';
    notifyListeners();
  }

  Future<void> updateCardControls(CardControls controls) async {
    await _run(() async {
      _snapshot = await _cardRepository.updateControls(
        snapshot: snapshot,
        controls: controls,
      );
      _message = 'Card controls updated';
    });
  }

  Future<void> updateSettings(UserSettings settings) async {
    await _run(() async {
      _snapshot = await _profileRepository.updateSettings(
        snapshot: snapshot,
        settings: settings,
      );
      _message = 'Profile preferences saved';
    });
  }

  Future<void> addSystemActivity(String title, String subtitle) async {
    final activity = ActivityEvent(
      id: 'act-${DateTime.now().microsecondsSinceEpoch}',
      type: ActivityType.system,
      title: title,
      subtitle: subtitle,
      amount: 0,
      createdAt: DateTime.now(),
    );
    _snapshot = await _portfolioRepository.saveSnapshot(
      snapshot.copyWith(activities: [activity, ...activities]),
    );
    _message = title;
    notifyListeners();
  }

  String generateReport() {
    return 'Astra Crypto Report\n'
        'Portfolio: \$${portfolioValue.toStringAsFixed(2)}\n'
        'Cash: \$${cashBalance.toStringAsFixed(2)}\n'
        'Crypto: \$${cryptoValue.toStringAsFixed(2)}\n'
        'Unrealized P/L: \$${unrealizedPnL.toStringAsFixed(2)} '
        '(${unrealizedPnLPercent.toStringAsFixed(2)}%)\n'
        'Holdings: ${holdings.length}\n'
        'Orders: ${orders.length}\n'
        'Transfers: ${transfers.length}';
  }

  void clearMessage() {
    _message = null;
  }

  Future<bool> _run(Future<void> Function() action) async {
    _busy = true;
    _message = null;
    notifyListeners();
    try {
      await action();
      _busy = false;
      notifyListeners();
      return true;
    } on CryptoBackendException catch (error) {
      _busy = false;
      _message = error.message;
      notifyListeners();
      return false;
    } catch (error) {
      _busy = false;
      _message = 'Something went wrong: $error';
      notifyListeners();
      return false;
    }
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    required AppController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppController watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing from the widget tree.');
    return scope!.notifier!;
  }

  static AppController read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AppScope>();
    final scope = element?.widget as AppScope?;
    assert(scope != null, 'AppScope is missing from the widget tree.');
    return scope!.notifier!;
  }
}
