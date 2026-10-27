import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/core/widgets/custom_app_bar.dart';
import 'package:widget_flutter/models/merchant/merchant_order.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/merchant_provider.dart';

class MerchantOrderDetailScreen extends StatefulWidget {
  const MerchantOrderDetailScreen({super.key, this.order, this.orderId});

  final MerchantOrder? order;
  final int? orderId;

  @override
  State<MerchantOrderDetailScreen> createState() =>
      _MerchantOrderDetailScreenState();
}

class _MerchantOrderDetailScreenState extends State<MerchantOrderDetailScreen> {
  bool _updating = false;
  MerchantOrder? _order;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    if (_order == null && widget.orderId != null) {
      _loadOrder();
    }
  }

  Future<void> _loadOrder() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    try {
      final order = await context.read<MerchantProvider>().getOrder(token, widget.orderId!);
      if (mounted) setState(() => _order = order);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load order: $e')),
        );
      }
    }
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _updating = true);
    try {
      print('OrderDetail: updating order ${_order!.id} to status: $status');
      await context
          .read<MerchantProvider>()
          .updateOrderStatus(context.read<AuthProvider>(), _order!.id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order status updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('OrderDetail: update failed: $e');
      if (mounted) {
        String errorMsg = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $errorMsg'),
            backgroundColor: Colors.red,
          ),
        );
      }
      log(e.toString());
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    if (order == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final status = order.status;

    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: CustomAppBar(
        showNotification: false,
        title: 'Order #${order.id}',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: _statusColor(status),
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
                  if (order.createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      order.createdAt!,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Products',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ...order.items.map(
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${i.quantity}x ${i.name}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            '\$${(i.price * i.quantity).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${order.computedTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (status != 'completed' && status != 'cancelled')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Update Status',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [
                        if (status == 'pending')
                          ElevatedButton(
                            onPressed: _updating ? null : () => _updateStatus('accepted'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Accept'),
                          ),
                        if (status == 'pending')
                          ElevatedButton(
                            onPressed: _updating ? null : () => _updateStatus('cancelled'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Cancel'),
                          ),
                        if (status == 'accepted')
                          ElevatedButton(
                            onPressed: _updating ? null : () => _updateStatus('preparing'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Start Preparing'),
                          ),
                        if (status == 'preparing')
                          ElevatedButton(
                            onPressed: _updating ? null : () => _updateStatus('completed'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Mark Completed'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
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
      case 'preparing':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }
}
