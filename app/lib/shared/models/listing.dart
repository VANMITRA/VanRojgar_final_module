import '../../core/localization/forest_produce_dictionary.dart';
import '../utils/product_image.dart';
import 'gram_sabha.dart';

class ListingModel {
  final String id;
  final String ownerType;
  final String ownerId;
  final String gramSabhaId;
  final String titleMr;
  final String titleEn;
  final String? titleHi;
  final String? categoryId;
  final String? description;
  /// Shared with the livelihood module, e.g. honey, bamboo, herb (server core/productCode.js).
  final String? productCode;
  final double quantityAvailable;
  final String unit;
  final int pricePerUnitPaise;
  final String mode; // 'sell' | 'barter' | 'both'
  final String? barterWants;
  final String fulfilment; // 'pickup' | 'delivery' | 'both'
  final String village;
  final String taluka;
  final String district;
  final String status; // 'active' | 'paused' | 'sold_out' | 'rejected'
  final bool rightsNotOnRecord;
  final double? distanceKm;
  final GramSabhaModel? gramSabha;
  final String? sourceForestArea;
  final String? imageUrl;

  ListingModel({
    required this.id,
    required this.ownerType,
    required this.ownerId,
    required this.gramSabhaId,
    required this.titleMr,
    required this.titleEn,
    this.titleHi,
    this.categoryId,
    this.description,
    this.productCode,
    required this.quantityAvailable,
    required this.unit,
    required this.pricePerUnitPaise,
    this.mode = 'sell',
    this.barterWants,
    this.fulfilment = 'both',
    required this.village,
    required this.taluka,
    this.district = 'Nashik',
    this.status = 'active',
    this.rightsNotOnRecord = false,
    this.distanceKm,
    this.gramSabha,
    this.sourceForestArea,
    this.imageUrl,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    final titleMap = json['title'] as Map<String, dynamic>?;
    final flagsMap = json['flags'] as Map<String, dynamic>?;
    final provMap = json['provenance'] as Map<String, dynamic>?;

    GramSabhaModel? gs;
    if (json['gramSabha'] is Map<String, dynamic>) {
      gs = GramSabhaModel.fromJson(json['gramSabha']);
    } else if (json['gramSabhaId'] is Map<String, dynamic>) {
      gs = GramSabhaModel.fromJson(json['gramSabhaId']);
    }

    return ListingModel(
      id: json['_id'] ?? json['id'] ?? '',
      ownerType: json['ownerType'] ?? 'gramsabha',
      ownerId: json['ownerId'] is Map ? json['ownerId']['_id'] : (json['ownerId'] ?? ''),
      gramSabhaId: json['gramSabhaId'] is Map ? json['gramSabhaId']['_id'] : (json['gramSabhaId'] ?? ''),
      titleMr: titleMap?['mr'] ?? '',
      titleEn: titleMap?['en'] ?? '',
      titleHi: titleMap?['hi'],
      categoryId: json['categoryId'] is Map ? json['categoryId']['_id'] : json['categoryId'],
      description: json['description'],
      productCode: json['productCode'],
      quantityAvailable: (json['quantityAvailable'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] ?? 'kg',
      pricePerUnitPaise: (json['pricePerUnitPaise'] as num?)?.toInt() ?? 0,
      mode: json['mode'] ?? 'sell',
      barterWants: json['barterWants'],
      fulfilment: json['fulfilment'] ?? 'both',
      village: json['village'] ?? '',
      taluka: json['taluka'] ?? '',
      district: json['district'] ?? 'Nashik',
      status: json['status'] ?? 'active',
      rightsNotOnRecord: flagsMap?['rightsNotOnRecord'] ?? false,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      gramSabha: gs,
      sourceForestArea: provMap?['sourceForestArea'],
      imageUrl: json['imageUrl'] ?? (json['images'] is List && (json['images'] as List).isNotEmpty ? json['images'][0] : null),
    );
  }

  /// High quality photography URL for the product with deterministic natural fallback.
  String get displayImageUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) return imageUrl!;
    return productAsset(titleEn, titleMr);
  }

  /// Returns title adapted to active language (supporting Hindi translation fallback).
  String localizedTitle(String locale) {
    if (locale == 'hi' && titleHi != null && titleHi!.isNotEmpty) {
      return titleHi!;
    }
    return ForestProduceDictionary.resolveTitle(
      en: titleEn,
      mr: titleMr,
      locale: locale,
    );
  }

  /// Returns secondary subtitle adapted to active language.
  String localizedSubtitle(String locale) => ForestProduceDictionary.resolveSubtitle(
        en: titleEn,
        mr: titleMr,
        locale: locale,
      );
}

