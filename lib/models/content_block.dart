import 'dart:convert';
class ContentBlock {
  static const String typeText = 'text';
  static const String typeImage = 'image';
  final String type;
  final String text;
  final String imagePath;
  const ContentBlock({
    required this.type,
    this.text = '',
    this.imagePath = '',
  });
  bool get isImage => type == typeImage;
  bool get isText => type == typeText;
  ContentBlock copyWith({
    String? type,
    String? text,
    String? imagePath,
  }) {
    return ContentBlock(
      type: type ?? this.type,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      if (imagePath.isNotEmpty) 'path': imagePath,
    };
  }
  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] as String?) ?? typeText;
    return ContentBlock(
      type: type == typeImage ? typeImage : typeText,
      text: (json['text'] as String?) ?? '',
      imagePath: (json['path'] as String?) ?? '',
    );
  }
  static List<ContentBlock> listFromJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => ContentBlock.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }
  static String listToJson(List<ContentBlock> blocks) {
    return jsonEncode(blocks.map((b) => b.toJson()).toList());
  }
  static String joinedText(List<ContentBlock> blocks) {
    return blocks
        .map((b) => b.text.trim())
        .where((t) => t.isNotEmpty)
        .join('\n\n');
  }
  static List<String> imagePaths(List<ContentBlock> blocks) {
    return blocks
        .where((b) => b.isImage && b.imagePath.isNotEmpty)
        .map((b) => b.imagePath)
        .toList();
  }
}
