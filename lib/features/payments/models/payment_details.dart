class PaymentDetails {
  final bool success;
  final String transactionId;
  final String externalReference;
  final String status;
  final String processedAt;
  final double fees;
  final double netAmount;

  PaymentDetails({
    required this.success,
    required this.transactionId,
    required this.externalReference,
    required this.status,
    required this.processedAt,
    required this.fees,
    required this.netAmount,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PaymentDetails(
        success: false,
        transactionId: '',
        externalReference: '',
        status: '',
        processedAt: '',
        fees: 0.0,
        netAmount: 0.0,
      );
    }
    return PaymentDetails(
      success: json['success'] ?? false,
      transactionId: json['transaction_id'] ?? '',
      externalReference: json['external_reference'] ?? '',
      status: json['status'] ?? '',
      processedAt: json['processed_at'] ?? '',
      fees: (json['fees'] ?? 0).toDouble(),
      netAmount: (json['net_amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'transaction_id': transactionId,
      'external_reference': externalReference,
      'status': status,
      'processed_at': processedAt,
      'fees': fees,
      'net_amount': netAmount,
    };
  }
}