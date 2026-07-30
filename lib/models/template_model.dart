import 'template_block.dart';
class TemplateModel {
  final int id;
  final String title;
  final String imageUrl;
  final List<TemplateBlock> blocks;
  final String? suggestedDuration;
  final String? estBudget;
  const TemplateModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.blocks,
    this.suggestedDuration,
    this.estBudget,
  });
  String get content =>
      blocks.where((b) => b.isText).map((b) => b.text).join('\n\n');
}
