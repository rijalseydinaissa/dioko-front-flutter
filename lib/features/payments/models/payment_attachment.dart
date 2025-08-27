class PaymentAttachment {
  final String path;
  final String type;

  PaymentAttachment({
    required this.path,
    required this.type,
  });

  factory PaymentAttachment.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PaymentAttachment(path: '', type: '');
    }
    return PaymentAttachment(
      path: json['path'] ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'type': type,
    };
  }
}