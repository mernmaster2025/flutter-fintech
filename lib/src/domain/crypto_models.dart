enum OrderSide { buy, sell }

enum TransferType { deposit, withdraw, send }

enum ActivityType { trade, transfer, card, alert, system }

class CryptoAsset {
  const CryptoAsset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.price,
    required this.change24h,
    required this.marketCap,
    required this.sparkline,
  });

  final String id;
  final String symbol;
  final String name;
  final double price;
  final double change24h;
  final double marketCap;
  final List<double> sparkline;

  CryptoAsset copyWith({
    double? price,
    double? change24h,
    double? marketCap,
    List<double>? sparkline,
  }) {
    return CryptoAsset(
      id: id,
      symbol: symbol,
      name: name,
      price: price ?? this.price,
      change24h: change24h ?? this.change24h,
      marketCap: marketCap ?? this.marketCap,
      sparkline: sparkline ?? this.sparkline,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'symbol': symbol,
    'name': name,
    'price': price,
    'change24h': change24h,
    'marketCap': marketCap,
    'sparkline': sparkline,
  };

  factory CryptoAsset.fromJson(Map<String, dynamic> json) {
    return CryptoAsset(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      change24h: (json['change24h'] as num).toDouble(),
      marketCap: (json['marketCap'] as num).toDouble(),
      sparkline: (json['sparkline'] as List<dynamic>)
          .map((value) => (value as num).toDouble())
          .toList(),
    );
  }
}

class Holding {
  const Holding({
    required this.assetId,
    required this.quantity,
    required this.averageCost,
  });

  final String assetId;
  final double quantity;
  final double averageCost;

  Holding copyWith({double? quantity, double? averageCost}) {
    return Holding(
      assetId: assetId,
      quantity: quantity ?? this.quantity,
      averageCost: averageCost ?? this.averageCost,
    );
  }

  Map<String, dynamic> toJson() => {
    'assetId': assetId,
    'quantity': quantity,
    'averageCost': averageCost,
  };

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      assetId: json['assetId'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      averageCost: (json['averageCost'] as num).toDouble(),
    );
  }
}

class TradeOrder {
  const TradeOrder({
    required this.id,
    required this.assetId,
    required this.side,
    required this.usdAmount,
    required this.assetQuantity,
    required this.executionPrice,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String assetId;
  final OrderSide side;
  final double usdAmount;
  final double assetQuantity;
  final double executionPrice;
  final DateTime createdAt;
  final String status;

  Map<String, dynamic> toJson() => {
    'id': id,
    'assetId': assetId,
    'side': side.name,
    'usdAmount': usdAmount,
    'assetQuantity': assetQuantity,
    'executionPrice': executionPrice,
    'createdAt': createdAt.toIso8601String(),
    'status': status,
  };

  factory TradeOrder.fromJson(Map<String, dynamic> json) {
    return TradeOrder(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      side: OrderSide.values.byName(json['side'] as String),
      usdAmount: (json['usdAmount'] as num).toDouble(),
      assetQuantity: (json['assetQuantity'] as num).toDouble(),
      executionPrice: (json['executionPrice'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
    );
  }
}

class TransferRecord {
  const TransferRecord({
    required this.id,
    required this.type,
    required this.recipientId,
    required this.amount,
    required this.fee,
    required this.note,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final TransferType type;
  final String recipientId;
  final double amount;
  final double fee;
  final String note;
  final DateTime createdAt;
  final String status;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'recipientId': recipientId,
    'amount': amount,
    'fee': fee,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'status': status,
  };

  factory TransferRecord.fromJson(Map<String, dynamic> json) {
    return TransferRecord(
      id: json['id'] as String,
      type: TransferType.values.byName(json['type'] as String),
      recipientId: json['recipientId'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      note: json['note'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
    );
  }
}

class Recipient {
  const Recipient({
    required this.id,
    required this.name,
    required this.initials,
    required this.walletAddress,
    required this.network,
  });

  final String id;
  final String name;
  final String initials;
  final String walletAddress;
  final String network;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'initials': initials,
    'walletAddress': walletAddress,
    'network': network,
  };

  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      id: json['id'] as String,
      name: json['name'] as String,
      initials: json['initials'] as String,
      walletAddress: json['walletAddress'] as String,
      network: json['network'] as String,
    );
  }
}

class CardControls {
  const CardControls({
    required this.frozen,
    required this.merchantRadar,
    required this.travelMode,
  });

  final bool frozen;
  final bool merchantRadar;
  final bool travelMode;

  CardControls copyWith({bool? frozen, bool? merchantRadar, bool? travelMode}) {
    return CardControls(
      frozen: frozen ?? this.frozen,
      merchantRadar: merchantRadar ?? this.merchantRadar,
      travelMode: travelMode ?? this.travelMode,
    );
  }

  Map<String, dynamic> toJson() => {
    'frozen': frozen,
    'merchantRadar': merchantRadar,
    'travelMode': travelMode,
  };

  factory CardControls.fromJson(Map<String, dynamic> json) {
    return CardControls(
      frozen: json['frozen'] as bool,
      merchantRadar: json['merchantRadar'] as bool,
      travelMode: json['travelMode'] as bool,
    );
  }
}

class UserSettings {
  const UserSettings({
    required this.smartAlerts,
    required this.biometricApprovals,
    required this.dynamicTheme,
    required this.concierge,
  });

  final bool smartAlerts;
  final bool biometricApprovals;
  final bool dynamicTheme;
  final bool concierge;

  UserSettings copyWith({
    bool? smartAlerts,
    bool? biometricApprovals,
    bool? dynamicTheme,
    bool? concierge,
  }) {
    return UserSettings(
      smartAlerts: smartAlerts ?? this.smartAlerts,
      biometricApprovals: biometricApprovals ?? this.biometricApprovals,
      dynamicTheme: dynamicTheme ?? this.dynamicTheme,
      concierge: concierge ?? this.concierge,
    );
  }

  Map<String, dynamic> toJson() => {
    'smartAlerts': smartAlerts,
    'biometricApprovals': biometricApprovals,
    'dynamicTheme': dynamicTheme,
    'concierge': concierge,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      smartAlerts: json['smartAlerts'] as bool,
      biometricApprovals: json['biometricApprovals'] as bool,
      dynamicTheme: json['dynamicTheme'] as bool,
      concierge: json['concierge'] as bool,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.plan,
    required this.verified,
  });

  final String name;
  final String email;
  final String plan;
  final bool verified;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'plan': plan,
    'verified': verified,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      email: json['email'] as String,
      plan: json['plan'] as String,
      verified: json['verified'] as bool,
    );
  }
}

class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  final ActivityType type;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'subtitle': subtitle,
    'amount': amount,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ActivityEvent.fromJson(Map<String, dynamic> json) {
    return ActivityEvent(
      id: json['id'] as String,
      type: ActivityType.values.byName(json['type'] as String),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class CryptoAppSnapshot {
  const CryptoAppSnapshot({
    required this.cashBalance,
    required this.assets,
    required this.holdings,
    required this.orders,
    required this.transfers,
    required this.recipients,
    required this.activities,
    required this.watchlistIds,
    required this.cardControls,
    required this.settings,
    required this.profile,
  });

  final double cashBalance;
  final List<CryptoAsset> assets;
  final List<Holding> holdings;
  final List<TradeOrder> orders;
  final List<TransferRecord> transfers;
  final List<Recipient> recipients;
  final List<ActivityEvent> activities;
  final Set<String> watchlistIds;
  final CardControls cardControls;
  final UserSettings settings;
  final UserProfile profile;

  CryptoAppSnapshot copyWith({
    double? cashBalance,
    List<CryptoAsset>? assets,
    List<Holding>? holdings,
    List<TradeOrder>? orders,
    List<TransferRecord>? transfers,
    List<Recipient>? recipients,
    List<ActivityEvent>? activities,
    Set<String>? watchlistIds,
    CardControls? cardControls,
    UserSettings? settings,
    UserProfile? profile,
  }) {
    return CryptoAppSnapshot(
      cashBalance: cashBalance ?? this.cashBalance,
      assets: assets ?? this.assets,
      holdings: holdings ?? this.holdings,
      orders: orders ?? this.orders,
      transfers: transfers ?? this.transfers,
      recipients: recipients ?? this.recipients,
      activities: activities ?? this.activities,
      watchlistIds: watchlistIds ?? this.watchlistIds,
      cardControls: cardControls ?? this.cardControls,
      settings: settings ?? this.settings,
      profile: profile ?? this.profile,
    );
  }

  Map<String, dynamic> toJson() => {
    'cashBalance': cashBalance,
    'assets': assets.map((asset) => asset.toJson()).toList(),
    'holdings': holdings.map((holding) => holding.toJson()).toList(),
    'orders': orders.map((order) => order.toJson()).toList(),
    'transfers': transfers.map((transfer) => transfer.toJson()).toList(),
    'recipients': recipients.map((recipient) => recipient.toJson()).toList(),
    'activities': activities.map((activity) => activity.toJson()).toList(),
    'watchlistIds': watchlistIds.toList(),
    'cardControls': cardControls.toJson(),
    'settings': settings.toJson(),
    'profile': profile.toJson(),
  };

  factory CryptoAppSnapshot.fromJson(Map<String, dynamic> json) {
    return CryptoAppSnapshot(
      cashBalance: (json['cashBalance'] as num).toDouble(),
      assets: (json['assets'] as List<dynamic>)
          .map((item) => CryptoAsset.fromJson(item as Map<String, dynamic>))
          .toList(),
      holdings: (json['holdings'] as List<dynamic>)
          .map((item) => Holding.fromJson(item as Map<String, dynamic>))
          .toList(),
      orders: (json['orders'] as List<dynamic>)
          .map((item) => TradeOrder.fromJson(item as Map<String, dynamic>))
          .toList(),
      transfers: (json['transfers'] as List<dynamic>)
          .map((item) => TransferRecord.fromJson(item as Map<String, dynamic>))
          .toList(),
      recipients: (json['recipients'] as List<dynamic>)
          .map((item) => Recipient.fromJson(item as Map<String, dynamic>))
          .toList(),
      activities: (json['activities'] as List<dynamic>)
          .map((item) => ActivityEvent.fromJson(item as Map<String, dynamic>))
          .toList(),
      watchlistIds: (json['watchlistIds'] as List<dynamic>)
          .cast<String>()
          .toSet(),
      cardControls: CardControls.fromJson(
        json['cardControls'] as Map<String, dynamic>,
      ),
      settings: UserSettings.fromJson(json['settings'] as Map<String, dynamic>),
      profile: UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
    );
  }
}
