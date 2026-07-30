import 'dart:convert';
import 'content_block.dart';
class JourneyEntity {
  final int? id;
  final String title;
  final String? content;
  final String? photos;
  final String? coverImagePath;
  final String? tripStartDate;
  final String? tripEndDate;
  final String? tags;
  final double? tripSpend;
  final String? photoCaptions;
  final String? bodyBlocks;
  final String createdAt;
  final String updatedAt;
  const JourneyEntity({
    this.id,
    required this.title,
    this.content,
    this.photos,
    this.coverImagePath,
    this.tripStartDate,
    this.tripEndDate,
    this.tags,
    this.tripSpend,
    this.photoCaptions,
    this.bodyBlocks,
    required this.createdAt,
    required this.updatedAt,
  });
  factory JourneyEntity.fromMap(Map<String, dynamic> map) {
    return JourneyEntity(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String?,
      photos: map['photos'] as String?,
      coverImagePath: map['cover_image_path'] as String?,
      tripStartDate: map['trip_start_date'] as String?,
      tripEndDate: map['trip_end_date'] as String?,
      tags: map['tags'] as String?,
      tripSpend: (map['trip_spend'] as num?)?.toDouble(),
      photoCaptions: map['photo_captions'] as String?,
      bodyBlocks: map['body_blocks'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'photos': photos,
      'cover_image_path': coverImagePath,
      'trip_start_date': tripStartDate,
      'trip_end_date': tripEndDate,
      'tags': tags,
      'trip_spend': tripSpend,
      'photo_captions': photoCaptions,
      'body_blocks': bodyBlocks,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
  List<String> get photoList =>
      photos?.split(',').where((e) => e.isNotEmpty).toList() ?? [];
  Map<String, String> get captionMap {
    if (photoCaptions == null || photoCaptions!.isEmpty) return {};
    try {
      final decoded = jsonDecode(photoCaptions!);
      if (decoded is Map) {
        return decoded.map(
          (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
        );
      }
    } catch (_) {}
    return {};
  }
  String? captionFor(String relativePath) {
    final map = captionMap;
    if (map.isEmpty) return null;
    final key = relativePath.split('/').last;
    final value = map[key] ?? map[relativePath];
    if (value == null || value.isEmpty) return null;
    return value;
  }
  List<ContentBlock> get resolvedBlocks {
    final fromJson = ContentBlock.listFromJson(bodyBlocks);
    if (fromJson.isNotEmpty) return fromJson;
    return _legacyBlocks();
  }
  List<ContentBlock> _legacyBlocks() {
    final blocks = <ContentBlock>[];
    final intro = content?.trim() ?? '';
    if (intro.isNotEmpty) {
      blocks.add(ContentBlock(type: ContentBlock.typeText, text: intro));
    }
    final captions = captionMap;
    for (final relative in photoList) {
      final key = relative.split('/').last;
      final caption = captions[key] ?? captions[relative] ?? '';
      blocks.add(ContentBlock(
        type: ContentBlock.typeImage,
        imagePath: relative,
        text: caption,
      ));
    }
    return blocks;
  }
}
