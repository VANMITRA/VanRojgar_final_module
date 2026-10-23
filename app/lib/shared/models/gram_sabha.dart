class GramSabhaModel {
  final String id;
  final String nameMr;
  final String? nameEn;
  final String villageMr;
  final String? villageEn;
  final String taluka;
  final String district;
  final String verificationStatus; // 'pending' | 'verified' | 'verified_seed' | 'rejected'
  final List<String> rights;
  final double approvedAreaHa;
  final List<double>? coordinates;

  GramSabhaModel({
    required this.id,
    required this.nameMr,
    this.nameEn,
    required this.villageMr,
    this.villageEn,
    required this.taluka,
    this.district = 'Nashik',
    this.verificationStatus = 'pending',
    this.rights = const [],
    this.approvedAreaHa = 0,
    this.coordinates,
  });

  factory GramSabhaModel.fromJson(Map<String, dynamic> json) {
    final nameMap = json['name'] as Map<String, dynamic>?;
    final villageMap = json['village'] as Map<String, dynamic>?;
    final cfrMap = json['cfr'] as Map<String, dynamic>?;
    final locMap = json['location'] as Map<String, dynamic>?;

    List<double>? coords;
    if (locMap != null && locMap['coordinates'] is List) {
      coords = (locMap['coordinates'] as List).map((e) => (e as num).toDouble()).toList();
    }

    return GramSabhaModel(
      id: json['_id'] ?? json['id'] ?? '',
      nameMr: nameMap?['mr'] ?? '',
      nameEn: nameMap?['en'],
      villageMr: villageMap?['mr'] ?? '',
      villageEn: villageMap?['en'],
      taluka: json['taluka'] ?? '',
      district: json['district'] ?? 'Nashik',
      verificationStatus: json['verificationStatus'] ?? 'pending',
      rights: cfrMap?['rights'] != null ? List<String>.from(cfrMap!['rights']) : [],
      approvedAreaHa: (cfrMap?['approvedAreaHa'] as num?)?.toDouble() ?? 0,
      coordinates: coords,
    );
  }
}
