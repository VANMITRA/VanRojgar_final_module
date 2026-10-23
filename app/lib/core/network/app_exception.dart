class AppException implements Exception {
  final String code;
  final String message;
  final Map<String, dynamic>? fields;
  final String? phase;
  final String? requestId;

  AppException({
    required this.code,
    required this.message,
    this.fields,
    this.phase,
    this.requestId,
  });

  @override
  String toString() => 'AppException(code: $code, message: $message, requestId: $requestId)';

  String get localizedMessage {
    switch (code) {
      case 'UNAUTHENTICATED':
        return 'सत्र संपले आहे, कृपया पुन्हा लॉगिन करा (Please login again)';
      case 'FORBIDDEN':
        return 'या क्रियेसाठी परवानगी नाही (Access forbidden)';
      case 'INSUFFICIENT_STOCK':
        return 'उपलब्ध साठ्यापेक्षा जास्त मागणी केली आहे (Insufficient stock)';
      case 'BULK_REASON_REQUIRED':
        return 'मोठ्या प्रमाणातील मागणीसाठी वनसंवर्धनाचे कारण आवश्यक आहे (Bulk order reason required)';
      case 'RESTRICTED_ITEM':
        return 'हे संरक्षित वन उत्पादन विक्रीस प्रतिबंधित आहे (Restricted forest item)';
      case 'NETWORK_ERROR':
        return 'सर्व्हरशी संपर्क होऊ शकला नाही. इंटरनेट तपासा आणि पुन्हा प्रयत्न करा (Cannot reach server — check internet and retry)';
      case 'NOT_IMPLEMENTED':
        return 'हे वैशिष्ट्य पुढील आवृत्तीमध्ये उपलब्ध होईल (Planned for later phase)';
      case 'RATE_LIMITED':
        return 'खूप जास्त विनंत्या पाठवल्या आहेत, कृपया थोड्या वेळाने प्रयत्न करा (Too many requests, please try again shortly)';
      default:
        return message;
    }
  }
}
