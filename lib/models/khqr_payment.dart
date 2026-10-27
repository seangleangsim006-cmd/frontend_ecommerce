class KhqrPayment {
  final int paymentId;
  final int orderId;
  final String transactionId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String qr;
  final String md5;
  final String status;
  final DateTime? expiresAt;
  final int? providerErrorCode;
  final String? providerErrorMessage;

  const KhqrPayment({
    required this.paymentId,
    required this.orderId,
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.qr,
    required this.md5,
    required this.status,
    required this.expiresAt,
    this.providerErrorCode,
    this.providerErrorMessage,
  });

  factory KhqrPayment.fromJson(Map<String, dynamic> json) {
    final nestedPayment = json['payment'] is Map<String, dynamic>
      ? json['payment'] as Map<String, dynamic>
      : const <String, dynamic>{};
    final status = json['status'] ??
      json['payment_status'] ??
      json['paymentStatus'] ??
      json['transaction_status'] ??
      json['transactionStatus'] ??
      json['payment_state'] ??
      json['state'] ??
      nestedPayment['status'] ??
      nestedPayment['payment_status'] ??
      nestedPayment['paymentStatus'];
    final isPaid = json['is_paid'] == true ||
      json['isPaid'] == true ||
      nestedPayment['is_paid'] == true ||
      nestedPayment['isPaid'] == true;
    final providerResponse = json['bakong_response'] is Map<String, dynamic>
        ? json['bakong_response'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return KhqrPayment(
      paymentId: _toInt(json['payment_id']),
      orderId: _toInt(json['order_id']),
      transactionId: json['transaction_id']?.toString() ?? '',
      amount: _toDouble(json['amount']),
      currency: json['currency']?.toString() ?? 'USD',
      paymentMethod: json['payment_method']?.toString() ?? 'khqr',
      qr: json['qr']?.toString() ?? '',
      md5: json['md5']?.toString() ?? '',
      status: isPaid ? 'paid' : status?.toString() ?? 'pending',
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
      providerErrorCode: _toNullableInt(providerResponse['errorCode']),
      providerErrorMessage: providerResponse['responseMessage']?.toString(),
    );
  }

  KhqrPayment copyWith({String? status}) {
    return KhqrPayment(
      paymentId: paymentId,
      orderId: orderId,
      transactionId: transactionId,
      amount: amount,
      currency: currency,
      paymentMethod: paymentMethod,
      qr: qr,
      md5: md5,
      status: status ?? this.status,
      expiresAt: expiresAt,
      providerErrorCode: providerErrorCode,
      providerErrorMessage: providerErrorMessage,
    );
  }

  static int _toInt(dynamic value) => int.tryParse(value.toString()) ?? 0;

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}