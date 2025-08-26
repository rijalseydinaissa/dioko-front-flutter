class Payment {
  final String id;
  final String description;
  final double amount;
  final String status; // pending, success, failed, canceled
  final DateTime createdAt;
  final String? proofUrl; // download/view
  final String? type; // internet, eau, etc.

  Payment({
    required this.id,
    required this.description,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.proofUrl,
    this.type,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: (json['id'] ?? json['uuid'] ?? json['payment_id']).toString(),
      description: json['description']?.toString() ?? '',
      amount: (json['amount'] as num).toDouble(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      proofUrl: json['proof_url']?.toString(),
      type: json['type']?.toString(),
    );
  }
}

enum HistoryFilter { day, month, year }