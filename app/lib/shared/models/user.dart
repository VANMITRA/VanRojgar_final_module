class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? businessName;
  final String? city;
  final String role; // 'gramsabha' | 'villager' (farmer) | 'cfrholder' | 'buyer'
  final String language;
  final String? gramSabhaId;
  final String? village;
  final String? taluka;
  final String district;
  final bool isDeliveryApplicant;
  final String status;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.businessName,
    this.city,
    required this.role,
    this.language = 'mr',
    this.gramSabhaId,
    this.village,
    this.taluka,
    this.district = 'Nashik',
    this.isDeliveryApplicant = false,
    this.status = 'active',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      businessName: json['businessName'],
      city: json['city'],
      role: json['role'] ?? 'villager',
      language: json['language'] ?? 'mr',
      gramSabhaId: json['gramSabhaId'] is Map ? json['gramSabhaId']['_id'] : json['gramSabhaId'],
      village: json['village'],
      taluka: json['taluka'],
      district: json['district'] ?? 'Nashik',
      isDeliveryApplicant: json['isDeliveryApplicant'] ?? false,
      status: json['status'] ?? 'active',
    );
  }
}
