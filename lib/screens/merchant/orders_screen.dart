import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/core/widgets/custom_app_bar.dart';
import 'package:widget_flutter/models/merchant/merchant_order.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/merchant_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _filter = 'all';

  final List<String> _filters = [
    'all',
    'pending',
    'accepted',
    'completed',
    'cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    final merchant = context.watch<MerchantProvider>();
    final orders = _filter == 'all'
        ? merchant.orders
        : merchant.orders.where((o) => o.status == _filter).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: const CustomAppBar(
        showNotification: false,
        title: 'Orders',
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final f = _filters[index];
                final selected = f == _filter;
                return ChoiceChip(
                  label: Text(f[0].toUpperCase() + f.substring(1)),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  onSelected: (_) => setState(() => _filter = f),
                );
              },
            ),
          ),
          Expanded(
            child: merchant.loading && merchant.orders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? const Center(child: Text('No orders'))
                    : RefreshIndicator(
                        onRefresh: () => merchant
                            .loadAll(context.read<AuthProvider>()),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: orders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return GestureDetector(
                              onTap: () => context.push(
                                '/merchant/orders/${order.id}',
                                extra: order,
                              ),
                              child: _OrderCard(order: order),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final MerchantOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final merchant = context.read<MerchantProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor(order.status),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.customerName ?? 'Customer',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          ...order.items.map(
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${i.quantity}x ${i.name}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    '\$${(i.price * i.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \$${order.computedTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
                      if (order.status != 'completed' && order.status != 'cancelled')
                        PopupMenuButton<String>(
                          onSelected: (status) => merchant.updateOrderStatus(
                            context.read<AuthProvider>(),
                            order.id,
                            status,
                          ),
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'accepted', child: Text('Accept')),
                            PopupMenuItem(value: 'completed', child: Text('Complete')),
                            PopupMenuItem(
                              value: 'cancelled',
                              child: Text('Cancel', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'accepted':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }
}
