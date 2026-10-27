import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/customer_order_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<CustomerOrderProvider>().fetchOrderHistory(auth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<CustomerOrderProvider>();
    final historyOrders = orderProvider.historyOrders;

    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xffF8F8F8),
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go(AppRoute.orders),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
        ),
        title: const Text('Order History', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: historyOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 90, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No completed or cancelled orders yet', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: historyOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = historyOrders[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(order.restaurantName, style: TextStyle(color: Colors.grey.shade700)),
                            const SizedBox(height: 4),
                            Text('${order.items.length} item${order.items.length > 1 ? 's' : ''}', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: order.status == 'cancelled' ? Colors.red.withOpacity(0.12) : Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.status == 'cancelled' ? 'Cancelled' : 'Completed',
                          style: TextStyle(
                            color: order.status == 'cancelled' ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
