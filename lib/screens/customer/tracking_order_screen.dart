import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/core/widgets/custom_app_bar.dart';
import 'package:widget_flutter/models/customer_order.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/customer_order_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';
import 'package:widget_flutter/widgets/cached_image.dart';

class CustomerOrderDetailScreen extends StatefulWidget {
  const CustomerOrderDetailScreen({super.key, required this.order});

  final CustomerOrder order;

  @override
  State<CustomerOrderDetailScreen> createState() =>
      _CustomerOrderDetailScreenState();
}

class _CustomerOrderDetailScreenState extends State<CustomerOrderDetailScreen> {
  bool _updating = false;

  Future<void> _markDelivered() async {
    setState(() => _updating = true);
    try {
      await context.read<CustomerOrderProvider>().updateOrderStatus(
        context.read<AuthProvider>(),
        widget.order.id,
        'delivered',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order marked as delivered'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final provider = context.read<CustomerOrderProvider>();
      provider.fetchOrders(auth);
      provider.startPolling(auth);
    });
  }

  @override
  void dispose() {
    context.read<CustomerOrderProvider>().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<CustomerOrderProvider>();
    final order = orderProvider.orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );
    final status = order.status;

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      appBar: CustomAppBar(
        showNotification: false,
        title: 'Order #${order.id}',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (status == 'pending')
              const _MapPreviewCard()
            else
              _StatusCard(status: status, createdAt: order.createdAt),
            const SizedBox(height: 14),
            _TrackingTimeline(status: status),
            const SizedBox(height: 14),
            _OrderSummaryCard(order: order),
            if (order.canConfirmDelivery) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _updating ? null : _markDelivered,
                  icon: _updating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _updating ? 'Updating order...' : 'Mark as Delivered',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go(AppRoute.mianNav),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Back to Home'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        height: 220,
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(11.5564, 104.9282),
            zoom: 14.5,
          ),
          mapType: MapType.normal,
          zoomControlsEnabled: false,
          compassEnabled: false,
          myLocationButtonEnabled: false,
          rotateGesturesEnabled: false,
          scrollGesturesEnabled: false,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: false,
          liteModeEnabled: true,
        ),
      ),
    );
  }
}

class _TrackingTimeline extends StatelessWidget {
  final String status;

  const _TrackingTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Order placed', Icons.receipt_long_outlined, true),
      ('Restaurant accepted', Icons.check_circle_outline, _stepActive(1)),
      ('Preparing your food', Icons.restaurant_outlined, _stepActive(2)),
      ('Delivered', Icons.home_outlined, _stepActive(3)),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Track your order',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            _timelineMessage(status),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                final completed = _stepCompleted(index ~/ 2);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      height: 2,
                      color: completed
                          ? AppColors.primary.withValues(alpha: 0.45)
                          : Colors.grey.shade200,
                    ),
                  ),
                );
              }

              final stepIndex = index ~/ 2;
              final step = steps[stepIndex];
              final active = step.$3;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step.$2,
                        size: 18,
                        color: active
                            ? AppColors.primary
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.$1,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.2,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active
                            ? Colors.grey.shade900
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  bool _stepActive(int step) {
    final current = switch (status) {
      'accepted' => 1,
      'preparing' => 2,
      'completed' || 'delivered' => 3,
      _ => 0,
    };
    return step <= current;
  }

  bool _stepCompleted(int step) => _stepActive(step + 1);

  String _timelineMessage(String value) {
    switch (value) {
      case 'accepted':
        return 'The restaurant has accepted your order.';
      case 'preparing':
        return 'Your meal is being prepared fresh.';
      case 'completed':
      case 'delivered':
        return 'Enjoy your meal. Your order is complete.';
      case 'cancelled':
        return 'This order was cancelled.';
      default:
        return 'We are waiting for the restaurant to confirm it.';
    }
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final CustomerOrder order;

  const _OrderSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: order.restaurantLogoUrl != null
                    ? CachedImage(
                        order.restaurantLogoUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 44,
                        height: 44,
                        color: const Color(0xFFFFEBDD),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: AppColors.primary,
                        ),
                      ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'From',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.restaurantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),
          const Text(
            'Your order',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      item.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '\$${item.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Order #${order.id}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String status;
  final String? createdAt;

  const _StatusCard({required this.status, this.createdAt});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final message = _statusMessage(status);
    final subtitle = _statusSubtitle(status);
    final icon = _statusIcon(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          if (status == 'accepted' || status == 'preparing') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated preparation: 20 minutes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusMessage(String status) {
    switch (status) {
      case 'completed':
        return 'Order Completed';
      case 'cancelled':
        return 'Order Cancelled';
      case 'accepted':
        return 'Restaurant Accepted Your Order';
      case 'preparing':
        return 'Preparing Your Food';
      default:
        return 'Waiting for Confirmation';
    }
  }

  String _statusSubtitle(String status) {
    switch (status) {
      case 'completed':
        return 'Your order has been completed.';
      case 'cancelled':
        return 'This order was cancelled.';
      case 'accepted':
        return 'The restaurant has accepted your order and will start preparing it soon.';
      case 'preparing':
        return 'The restaurant is currently preparing your food.';
      default:
        return 'Waiting for the restaurant to accept your order.';
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.restaurant_outlined;
      default:
        return Icons.pending_outlined;
    }
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
