import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/providers/customer_order_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';

class ActiveOrderBanner extends StatelessWidget {
  const ActiveOrderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<CustomerOrderProvider>();
    final orders = orderProvider.orders;
    final activeOrders = orders
        .where(
          (o) =>
              o.status == 'pending' ||
              o.status == 'accepted' ||
              o.status == 'preparing',
        )
        .toList();

    if (activeOrders.isEmpty) return const SizedBox.shrink();

    final pendingCount = orders.where((o) => o.status == 'pending').length;
    final acceptedCount = orders.where((o) => o.status == 'accepted').length;
    final preparingCount = orders.where((o) => o.status == 'preparing').length;

    String message;
    Color bgColor;
    Color textColor;

    if (preparingCount > 0) {
      message =
          '$preparingCount order${preparingCount > 1 ? 's' : ''} being prepared';
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade900;
    } else if (acceptedCount > 0) {
      message = '$acceptedCount order${acceptedCount > 1 ? 's' : ''} accepted';
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue.shade900;
    } else {
      message = '$pendingCount pending order${pendingCount > 1 ? 's' : ''}';
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade900;
    }

    final targetOrder = activeOrders.firstWhere(
      (order) => order.status == 'preparing',
      orElse: () => activeOrders.firstWhere(
        (order) => order.status == 'accepted',
        orElse: () => activeOrders.first,
      ),
    );

    return InkWell(
      onTap: () => context.push(AppRoute.orderDetail, extra: targetOrder),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: textColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(
              preparingCount > 0
                  ? Icons.restaurant_rounded
                  : acceptedCount > 0
                  ? Icons.check_circle_rounded
                  : Icons.pending_actions_rounded,
              color: textColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textColor, size: 20),
          ],
        ),
      ),
    );
  }
}
