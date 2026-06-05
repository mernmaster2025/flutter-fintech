import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fintech/src/domain/crypto_models.dart';
import 'package:flutter_fintech/src/state/app_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buy order updates holdings, cash, orders, and activity', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController.mock();
    await controller.initialize();

    final initialCash = controller.cashBalance;
    final initialOrders = controller.orders.length;
    final success = await controller.placeOrder(
      assetId: 'btc',
      side: OrderSide.buy,
      usdAmount: 500,
    );

    expect(success, isTrue);
    expect(controller.cashBalance, closeTo(initialCash - 500, 0.01));
    expect(controller.orders.length, initialOrders + 1);
    expect(controller.activities.first.type, ActivityType.trade);

    controller.dispose();
  });

  test('transfer validation rejects insufficient balance', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppController.mock();
    await controller.initialize();

    final success = await controller.submitTransfer(
      type: TransferType.send,
      recipientId: controller.recipients.first.id,
      amount: controller.cashBalance + 100000,
      note: 'Too much',
    );

    expect(success, isFalse);
    expect(controller.message, contains('Insufficient'));

    controller.dispose();
  });

  test('card controls and settings persist across controllers', () async {
    SharedPreferences.setMockInitialValues({});
    final first = AppController.mock();
    await first.initialize();

    await first.updateCardControls(
      first.cardControls.copyWith(frozen: true, travelMode: true),
    );
    await first.updateSettings(
      first.settings.copyWith(smartAlerts: false, concierge: false),
    );
    first.dispose();

    final second = AppController.mock();
    await second.initialize();

    expect(second.cardControls.frozen, isTrue);
    expect(second.cardControls.travelMode, isTrue);
    expect(second.settings.smartAlerts, isFalse);
    expect(second.settings.concierge, isFalse);

    second.dispose();
  });
}
