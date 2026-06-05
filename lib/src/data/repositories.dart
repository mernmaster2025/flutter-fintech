import '../domain/crypto_models.dart';

abstract class MarketRepository {
  Future<List<CryptoAsset>> refreshMarkets();

  Stream<List<CryptoAsset>> watchMarketTicks();
}

abstract class PortfolioRepository {
  Future<CryptoAppSnapshot> loadSnapshot();

  Future<CryptoAppSnapshot> saveSnapshot(CryptoAppSnapshot snapshot);
}

abstract class OrderRepository {
  Future<CryptoAppSnapshot> placeOrder({
    required CryptoAppSnapshot snapshot,
    required String assetId,
    required OrderSide side,
    required double usdAmount,
  });
}

abstract class TransferRepository {
  Future<CryptoAppSnapshot> submitTransfer({
    required CryptoAppSnapshot snapshot,
    required TransferType type,
    required String recipientId,
    required double amount,
    required String note,
  });
}

abstract class ProfileRepository {
  Future<CryptoAppSnapshot> updateSettings({
    required CryptoAppSnapshot snapshot,
    required UserSettings settings,
  });
}

abstract class CardRepository {
  Future<CryptoAppSnapshot> updateControls({
    required CryptoAppSnapshot snapshot,
    required CardControls controls,
  });
}
