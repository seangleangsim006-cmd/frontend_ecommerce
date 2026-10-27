import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/models/customer_order.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/customer_order_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';
import 'package:widget_flutter/widgets/active_order_banner.dart';
import 'package:widget_flutter/widgets/cached_image.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late final CustomerOrderProvider _orderProvider;

  @override
  void initState() {
    super.initState();
    _orderProvider = context.read<CustomerOrderProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      _orderProvider.fetchOrders(auth);
      _orderProvider.startPolling(auth);
    });
  }

  @override
  void dispose() {
    _orderProvider.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerOrderProvider>();
    final orders = provider.orders
        .where((order) => order.isActiveOrder)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF8),
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go(AppRoute.mianNav),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoute.orderHistory),
            icon: const Icon(Icons.history_rounded, size: 18),
            label: const Text('History'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          const ActiveOrderBanner(),
          if (orders.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
              child: Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${orders.length} active order${orders.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Updates automatically',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          Expanded(
            child: provider.loading && orders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.message != null && orders.isEmpty
                ? _ErrorState(
                    message: provider.message!,
                    onRetry: () => _orderProvider.fetchOrders(
                      context.read<AuthProvider>(),
                    ),
                  )
                : orders.isEmpty
                ? _EmptyOrders(onBrowse: () => context.go(AppRoute.home))
                : RefreshIndicator(
                    onRefresh: () =>
                        _orderProvider.refresh(context.read<AuthProvider>()),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _OrderCard(
                        order: orders[index],
                        onTap: () => context.push(
                          AppRoute.orderDetail,
                          extra: orders[index],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final CustomerOrder order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);

    return Semantics(
      button: true,
      label: 'Order ${order.id} from ${order.restaurantName}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: order.restaurantLogoUrl != null
                        ? CachedImage(
                            order.restaurantLogoUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 48,
                            height: 48,
                            color: const Color(0xFFFFEBDD),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.restaurantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Order #${order.id}  •  ${_formatDate(order.createdAt)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _StatusChip(
                        label: _statusLabel(order.status),
                        icon: _statusIcon(order.status),
                        color: statusColor,
                      ),
                      const SizedBox(height: 5),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _ProgressLine(status: order.status),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      _itemPreview(order),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order total',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View details',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final String status;

  const _ProgressLine({required this.status});

  @override
  Widget build(BuildContext context) {
    final activeStep = status == 'pending'
        ? 0
        : status == 'accepted'
        ? 1
        : 2;
    const labels = ['Placed', 'Accepted', 'Preparing'];

    return Row(
      children: List.generate(labels.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: index ~/ 2 < activeStep
                  ? AppColors.primary
                  : Colors.grey.shade200,
            ),
          );
        }
        final step = index ~/ 2;
        final active = step <= activeStep;
        return Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              labels[step],
              style: TextStyle(
                color: active ? AppColors.primary : Colors.grey.shade500,
                fontSize: 9,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  final VoidCallback onBrowse;

  const _EmptyOrders({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: const BoxDecoration(
              color: Color(0xFFFFEBDD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No active orders',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Your current orders will appear here.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onBrowse,
            icon: const Icon(Icons.restaurant_menu_rounded),
            label: const Text('Browse restaurants'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(190, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 54,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            const Text(
              'Could not load orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _itemPreview(CustomerOrder order) {
  if (order.items.isEmpty) return 'No item details available';
  final names = order.items.take(2).map((item) => item.productName).join(', ');
  final extra = order.items.length > 2 ? ' +${order.items.length - 2}' : '';
  return '$names$extra  •  ${order.items.length} item${order.items.length == 1 ? '' : 's'}';
}

String _formatDate(String? value) {
  if (value == null || value.isEmpty) return 'Recently placed';
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return 'Recently placed';
  return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
}

Color _statusColor(String status) {
  switch (status) {
    case 'accepted':
      return Colors.blue;
    case 'preparing':
      return Colors.orange;
    default:
      return AppColors.primary;
  }
}

IconData _statusIcon(String status) {
  switch (status) {
    case 'accepted':
      return Icons.check_circle_rounded;
    case 'preparing':
      return Icons.restaurant_rounded;
    default:
      return Icons.pending_actions_rounded;
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'accepted':
      return 'Accepted';
    case 'preparing':
      return 'Preparing';
    default:
      return 'Pending';
  }
}
