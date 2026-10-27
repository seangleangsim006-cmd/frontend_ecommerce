import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:widget_flutter/core/constants/app_colors.dart';
import 'package:widget_flutter/core/widgets/app_button.dart';
import 'package:widget_flutter/models/customer_order.dart';
import 'package:widget_flutter/models/khqr_payment.dart';
import 'package:widget_flutter/providers/auth_provider.dart';
import 'package:widget_flutter/providers/address_provider.dart';
import 'package:widget_flutter/providers/cart_provider.dart';
import 'package:widget_flutter/providers/customer_order_provider.dart';
import 'package:widget_flutter/routes/app_route.dart';
import 'package:widget_flutter/services/product_service.dart';
import 'package:widget_flutter/services/payment_service.dart';
import 'package:widget_flutter/widgets/cached_image.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int? selectedPayment;
  String deliveryAddress = 'Street 2004, Phnom Penh';
  bool isPlacingOrder = false;

  Future<void> _placeOrder() async {
    final cartProvider = context.read<CartProvider>();
    final authProvider = context.read<AuthProvider>();
    if (cartProvider.cartItem.isEmpty) return;
    if (selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() => isPlacingOrder = true);

    try {
      final cartItems = List.of(cartProvider.cartItem);
      final firstItem = cartProvider.cartItem.first;
      final items = cartProvider.cartItem
          .map((item) => {
                "product_id": item.id,
                "quantity": item.qty,
              })
          .toList();

      final orderResponse = await ProductService.placeOrder(
        restaurantId: firstItem.restaurantId,
        items: items,
        token: authProvider.token,
      );

      final orderId = _orderIdFromResponse(orderResponse);
      if (selectedPayment == 0) {
        final payment = await PaymentService.createKhqr(
          orderId: orderId,
          token: authProvider.token ?? '',
        );
        if (!mounted) return;
        final paymentCompleted = await _showKhqrDialog(payment);
        if (!paymentCompleted) {
          await ProductService.updateCustomerOrderStatus(
            authProvider.token ?? '',
            orderId,
            'cancelled',
          );
          return;
        }
        cartProvider.clear();
      } else {
        cartProvider.clear();
      }

      if (mounted) {
        final order = await _resolveCreatedOrder(
          orderResponse,
          orderId,
          authProvider,
          cartItems,
        );
        if (!mounted) return;
        context.pushReplacement(AppRoute.orderDetail, extra: order);
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
        setState(() => isPlacingOrder = false);
      }
    }
  }

  Future<CustomerOrder> _resolveCreatedOrder(
    Map<String, dynamic> response,
    int orderId,
    AuthProvider authProvider,
    List<dynamic> cartItems,
  ) async {
    final data = response['data'];
    if (data is Map<String, dynamic> && data['id'] != null) {
      return CustomerOrder.fromJson(data);
    }

    final provider = context.read<CustomerOrderProvider>();
    await provider.fetchOrders(authProvider);
    for (final order in provider.orders) {
      if (order.id == orderId) return order;
    }

    return CustomerOrder(
      id: orderId,
      status: 'pending',
      total: cartItems.fold<double>(
        0,
        (sum, item) => sum + (item.price * item.qty),
      ),
      restaurantName: 'Restaurant',
      items: cartItems
          .map(
            (item) => CustomerOrderItem(
              id: 0,
              productId: item.id,
              productName: item.name,
              quantity: item.qty,
              price: item.price,
              productImage: item.imageUrl,
            ),
          )
          .toList(),
    );
  }

  void _showOrderSummary() {
    final items = context.read<CartProvider>().cartItem;
    final total = context.read<CartProvider>().total();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order summary',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedImage(
                            item.imageUrl ?? '',
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Qty: ${item.qty}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${(item.qty * item.price).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentMethodCard({
    required String name,
    required String account,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    final selected = selectedPayment == value;

    return Semantics(
      button: true,
      selected: selected,
      label: '$name payment method',
      child: GestureDetector(
        onTap: () {
          setState(() => selectedPayment = value);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF7F1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFEDEDED),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<int>(
                value: value,
                groupValue: selectedPayment,
                onChanged: (nextValue) {
                  if (nextValue != null) {
                    setState(() => selectedPayment = nextValue);
                  }
                },
                activeColor: AppColors.primary,
              ),
            ],

          ),
        ),
      ),
    );
  }

  int _orderIdFromResponse(Map<String, dynamic> response) {
    final data = response['data'];
    final rawId = data is Map<String, dynamic>
        ? data['id'] ?? data['order_id']
        : response['order_id'];
    final orderId = int.tryParse(rawId?.toString() ?? '');
    if (orderId == null) {
      throw Exception('Order was created but its ID was not returned');
    }
    return orderId;
  }

  Future<bool> _showKhqrDialog(KhqrPayment initialPayment) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _KhqrPaymentDialog(
        initialPayment: initialPayment,
        token: context.read<AuthProvider>().token ?? '',
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final selectedAddress = context.watch<AddressProvider>().selectedAddress;

    return Scaffold(
      backgroundColor: const Color(0xffF8F9FB),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(6),
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.neutral.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              "Review your order",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: AppButton(
            text: isPlacingOrder
                ? "Placing Order..."
                : "Place Order - \$${cartProvider.total().toStringAsFixed(2)}",
            onPressed: isPlacingOrder ? null : _placeOrder,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// TOTAL CARD
            GestureDetector(
              onTap: _showOrderSummary,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Payment Amount",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "\$${cartProvider.total().toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 21,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 24,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// DELIVERY ADDRESS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDEDED)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBDD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 27,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedAddress?.label ?? "Delivery Address",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          selectedAddress?.address ?? deliveryAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: () async {
                      await context.push(AppRoute.addresses);
                    },
                    child: Row(
                      children: const [
                        Text(
                          "Change",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),

            _paymentMethodCard(
              name: 'PayNow (KHQR)',
              account: 'Scan KHQR to pay securely',
              value: 0,
              color: const Color(0xFF1B6B46),
              icon: Icons.qr_code_2_rounded,
            ),
            _paymentMethodCard(
              name: 'Cash on delivery',
              account: 'Pay when your order arrives',
              value: 1,
              color: const Color(0xFFB56B16),
              icon: Icons.payments_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _KhqrPaymentDialog extends StatefulWidget {
  final KhqrPayment initialPayment;
  final String token;

  const _KhqrPaymentDialog({
    required this.initialPayment,
    required this.token,
  });

  @override
  State<_KhqrPaymentDialog> createState() => _KhqrPaymentDialogState();
}

class _KhqrPaymentDialogState extends State<_KhqrPaymentDialog> {
  late KhqrPayment payment;
  Timer? _pollTimer;
  String? errorMessage;
  bool isChecking = false;
  bool _pollingStopped = false;

  @override
  void initState() {
    super.initState();
    payment = widget.initialPayment;
    if (payment.status.isNotEmpty && _isPaid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop(true);
      });
      return;
    }
    _checkPayment();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkPayment();
    });
  }

  Future<void> _checkPayment() async {
    if (!mounted || isChecking || _isFinished) return;
    setState(() {
      isChecking = true;
      errorMessage = null;
    });

    try {
      final result = await PaymentService.checkPayment(
        paymentId: payment.paymentId,
        token: widget.token,
      );
      if (!mounted) return;
      setState(() => payment = payment.copyWith(status: result.status));
      if (result.providerErrorCode == 17) {
        _pollTimer?.cancel();
        setState(() {
          _pollingStopped = true;
          errorMessage = result.providerErrorMessage ??
              'Payment verification limit reached. Please try again tomorrow.';
        });
        return;
      }
      if (_isPaid) {
        _pollTimer?.cancel();
        Navigator.of(context).pop(true);
      } else if (_isFinished) {
        _pollTimer?.cancel();
      }
    } catch (error) {
      if (mounted) {
        if (error is PaymentServiceException && error.statusCode >= 500) {
          log('Temporary payment check failure (${error.statusCode}): $error');
          setState(() => errorMessage = null);
          return;
        }
        log('Failed to check payment: $error');
        setState(() {
          errorMessage = error.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => isChecking = false);
    }
  }

  String get _normalizedStatus => payment.status
      .toLowerCase()
      .trim()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'_+'), '_')
    .replaceAll(RegExp(r'^_|_$'), '');

  bool get _isPaid => [
        'paid',
        'completed',
        'success',
      'successful',
      'settled',
      'succeeded',
      'transferred',
        'payment_success',
        'payment_successful',
        'successfully_paid',
      'transaction_success',
      'transaction_successful',
      'transaction_completed',
      'payment_completed',
      'payment_settled',
      'order_paid',
        'approved',
        'confirmed',
        'ready',
      ].contains(_normalizedStatus);
  bool get _isFinished =>
      _isPaid || ['expired', 'failed'].contains(_normalizedStatus);

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPending = !_isFinished && !_pollingStopped;
    final statusText = _isPaid
        ? 'Payment received successfully.'
      : _normalizedStatus == 'expired'
            ? 'This QR code has expired.'
        : _normalizedStatus == 'failed'
                ? 'Payment failed. Please try again.'
                : 'Scan this QR with your banking app.';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Pay with KHQR'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (payment.qr.isNotEmpty && isPending)
              Container(
                width: 280,
                height: 280,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEDEDED)),
                ),
                child: QrImageView(
                  data: payment.qr,
                  version: QrVersions.auto,
                  errorCorrectionLevel: QrErrorCorrectLevel.L,
                  gapless: false,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                ),
              )
            else
              Icon(
                _isPaid ? Icons.check_circle : Icons.info_outline,
                color: _isPaid ? Colors.green : AppColors.primary,
                size: 72,
              ),
            const SizedBox(height: 14),
            Text(
              '\$${payment.amount.toStringAsFixed(2)} ${payment.currency}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(statusText, textAlign: TextAlign.center),
            if (isPending) ...[
              const SizedBox(height: 12),
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            isPending ? 'Cancel' : 'Done',
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
        if (isPending && errorMessage != null)
          TextButton(
            onPressed: _checkPayment,
            child: const Text('Retry'),
          ),
      ],
    );
  }
}
