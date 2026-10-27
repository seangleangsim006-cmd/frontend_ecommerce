import 'package:flutter_test/flutter_test.dart';
import 'package:widget_flutter/core/constants/api_url.dart';
import 'package:widget_flutter/models/customer_order.dart';

void main() {
  test('CustomerOrder resolves restaurant logo through ApiUrl', () {
    final order = CustomerOrder.fromJson({
      'id': 1,
      'status': 'accepted',
      'total': 15.5,
      'restaurant': {
        'name': 'Pizza Place',
        'logo': 'restaurants/logo.png',
      },
      'items': [],
    });

    expect(order.restaurantLogoUrl, '${ApiUrl.storageBase}/restaurants/logo.png');
  });

  test('CustomerOrder allows delivery confirmation while in transit', () {
    final acceptedOrder = CustomerOrder.fromJson({
      'id': 2,
      'status': 'accepted',
      'total': 9.0,
      'restaurant': {'name': 'Cafe', 'logo': null},
      'items': [],
    });
    final preparingOrder = CustomerOrder.fromJson({
      'id': 3,
      'status': 'preparing',
      'total': 9.0,
      'restaurant': {'name': 'Cafe', 'logo': null},
      'items': [],
    });
    final completedOrder = CustomerOrder.fromJson({
      'id': 4,
      'status': 'completed',
      'total': 9.0,
      'restaurant': {'name': 'Cafe', 'logo': null},
      'items': [],
    });

    expect(acceptedOrder.canConfirmDelivery, isTrue);
    expect(preparingOrder.canConfirmDelivery, isTrue);
    expect(completedOrder.canConfirmDelivery, isFalse);
  });
}
