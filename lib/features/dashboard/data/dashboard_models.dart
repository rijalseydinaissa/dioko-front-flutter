class Stats {
  final String balance;
  final int totalPayments;
  final int completedPayments;
  final int pendingPayments;
  final int failedPayments;
  final String totalAmountSpent;
  final int thisMonthPayments;
  final String thisMonthAmount;
  final double successRate;

  Stats({
    required this.balance,
    required this.totalPayments,
    required this.completedPayments,
    required this.pendingPayments,
    required this.failedPayments,
    required this.totalAmountSpent,
    required this.thisMonthPayments,
    required this.thisMonthAmount,
    required this.successRate,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      balance: json['balance']?.toString() ?? '0',
      totalPayments: json['total_payments'] ?? 0,
      completedPayments: json['completed_payments'] ?? 0,
      pendingPayments: json['pending_payments'] ?? 0,
      failedPayments: json['failed_payments'] ?? 0,
      totalAmountSpent: json['total_amount_spent']?.toString() ?? '0',
      thisMonthPayments: json['this_month_payments'] ?? 0,
      thisMonthAmount: json['this_month_amount']?.toString() ?? '0',
      successRate: (json['success_rate'] ?? 0).toDouble(),
    );
  }
}

class PaymentType {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String icon;
  final bool isActive;

  PaymentType({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.icon,
    required this.isActive,
  });

  factory PaymentType.fromJson(Map<String, dynamic> json) {
    return PaymentType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}

class PaymentAttachment {
  final String path;
  final String type;

  PaymentAttachment({required this.path, required this.type});

  factory PaymentAttachment.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PaymentAttachment(path: '', type: '');
    }
    return PaymentAttachment(
      path: json['path'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

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
}

class Payment {
  final int id;
  final String paymentReference;
  final String externalReference;
  final String description;
  final String amount;
  final String status;
  final String statusLabel;
  final PaymentType paymentType;
  final PaymentAttachment? attachment;
  final PaymentDetails? paymentDetails;
  final String? failureReason;
  final String? processedAt;
  final String createdAt;
  final String updatedAt;

  Payment({
    required this.id,
    required this.paymentReference,
    required this.externalReference,
    required this.description,
    required this.amount,
    required this.status,
    required this.statusLabel,
    required this.paymentType,
    this.attachment,
    this.paymentDetails,
    this.failureReason,
    this.processedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters utiles pour les statuts
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isFailed => status.toLowerCase() == 'failed';

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      paymentReference: json['payment_reference'] ?? '',
      externalReference: json['external_reference'] ?? '',
      description: json['description'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
      paymentType: PaymentType.fromJson(json['payment_type'] ?? {}),
      attachment: json['attachment'] != null
          ? PaymentAttachment.fromJson(json['attachment'])
          : null,
      paymentDetails: json['payment_details'] != null
          ? PaymentDetails.fromJson(json['payment_details'])
          : null,
      failureReason: json['failure_reason'],
      processedAt: json['processed_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_reference': paymentReference,
      'external_reference': externalReference,
      'description': description,
      'amount': amount,
      'status': status,
      'status_label': statusLabel,
      'payment_type': {
        'id': paymentType.id,
        'name': paymentType.name,
        'slug': paymentType.slug,
        'icon': paymentType.icon,
      },
      'attachment': attachment != null ? {
        'path': attachment!.path,
        'type': attachment!.type,
      } : null,
      'payment_details': paymentDetails != null ? {
        'success': paymentDetails!.success,
        'transaction_id': paymentDetails!.transactionId,
        'external_reference': paymentDetails!.externalReference,
        'status': paymentDetails!.status,
        'processed_at': paymentDetails!.processedAt,
        'fees': paymentDetails!.fees,
        'net_amount': paymentDetails!.netAmount,
      } : null,
      'failure_reason': failureReason,
      'processed_at': processedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}