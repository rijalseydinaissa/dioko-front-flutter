import '../models/payment_type.dart';
import '../models/payment_attachment.dart';
import '../models/payment_details.dart';

class Payment {
  final int id;
  final String paymentReference;
  final String? externalReference; // Peut être null
  final String description;
  final String amount;
  final String status;
  final String statusLabel;
  final PaymentType paymentType;
  final PaymentAttachment? attachment; // Peut être null
  final PaymentDetails? paymentDetails; // Peut être null
  final String? failureReason; // Peut être null
  final String? processedAt; // Peut être null
  final String createdAt;
  final String updatedAt;

  Payment({
    required this.id,
    required this.paymentReference,
    this.externalReference, // Nullable
    required this.description,
    required this.amount,
    required this.status,
    required this.statusLabel,
    required this.paymentType,
    this.attachment, // Nullable
    this.paymentDetails, // Nullable
    this.failureReason, // Nullable
    this.processedAt, // Nullable
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      paymentReference: json['payment_reference'] ?? '',
      externalReference: json['external_reference'], // Peut être null
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
      failureReason: json['failure_reason'], // Peut être null
      processedAt: json['processed_at'], // Peut être null
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  // Helper methods
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isFailed => status.toLowerCase() == 'failed';
  bool get canBeApproved => isPending;
  bool get canBeCancelled => isPending;

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