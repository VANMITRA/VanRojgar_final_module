import '../../core/localization/forest_produce_dictionary.dart';

class CategoryModel {
  final String id;
  final String slug;
  final String nameMr;
  final String nameEn;
  final String? nameHi;
  final String iconKey;
  final int order;

  CategoryModel({
    required this.id,
    required this.slug,
    required this.nameMr,
    required this.nameEn,
    this.nameHi,
    this.iconKey = 'category',
    this.order = 0,
  });

  /// Returns category name adapted to active language (supporting Hindi translation fallback).
  String localizedName(String locale) {
    if (locale == 'hi') {
      if (nameHi != null && nameHi!.isNotEmpty) return nameHi!;
      return ForestProduceDictionary.resolveTitle(
        en: nameEn,
        mr: nameMr,
        locale: locale,
      );
    }
    if (locale == 'mr') {
      return nameMr.isNotEmpty ? nameMr : nameEn;
    }
    return nameEn.isNotEmpty ? nameEn : nameMr;
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final nameMap = json['name'] as Map<String, dynamic>?;
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      slug: json['slug'] ?? '',
      nameMr: nameMap?['mr'] ?? '',
      nameEn: nameMap?['en'] ?? '',
      nameHi: nameMap?['hi'],
      iconKey: json['iconKey'] ?? 'category',
      order: json['order'] ?? 0,
    );
  }
}
