import '../../core/localization/forest_produce_dictionary.dart';

class MessageModel {
  final String id;
  final String type;
  final String? titleMr;
  final String? titleEn;
  final String? bodyMr;
  final String? bodyEn;
  final String? readAt;
  final String createdAt;

  MessageModel({
    required this.id,
    required this.type,
    this.titleMr,
    this.titleEn,
    this.bodyMr,
    this.bodyEn,
    this.readAt,
    required this.createdAt,
  });

  /// Returns title adapted to active language (supporting Hindi translation fallback).
  String localizedTitle(String locale) => ForestProduceDictionary.resolveTitle(
        en: titleEn,
        mr: titleMr,
        locale: locale,
      );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final titleMap = json['title'] as Map<String, dynamic>?;
    final bodyMap = json['body'] as Map<String, dynamic>?;
    return MessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? '',
      titleMr: titleMap?['mr'],
      titleEn: titleMap?['en'],
      bodyMr: bodyMap?['mr'],
      bodyEn: bodyMap?['en'],
      readAt: json['readAt'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}

