class TemplateBlock {
  static const typeText = 'text';
  static const typeImage = 'image';
  final String type;
  final String text;
  final String? imageAsset;
  final String? imageUrl;
  const TemplateBlock.text(this.text)
      : type = typeText,
        imageAsset = null,
        imageUrl = null;
  const TemplateBlock.asset(this.imageAsset, {this.text = ''})
      : type = typeImage,
        imageUrl = null;
  const TemplateBlock.network(this.imageUrl, {this.text = ''})
      : type = typeImage,
        imageAsset = null;
  bool get isImage => type == typeImage;
  bool get isText => type == typeText;
}
