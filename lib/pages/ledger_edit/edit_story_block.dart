import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/content_block.dart';
class EditStoryBlock {
  final String id;
  final String type;
  final TextEditingController textController;
  final imagePath = ''.obs;
  EditStoryBlock._({
    required this.id,
    required this.type,
    required String text,
    String path = '',
  }) : textController = TextEditingController(text: text) {
    imagePath.value = path;
  }
  factory EditStoryBlock.text({String text = ''}) {
    return EditStoryBlock._(
      id: _newId(),
      type: ContentBlock.typeText,
      text: text,
    );
  }
  factory EditStoryBlock.image({
    required String path,
    String text = '',
  }) {
    return EditStoryBlock._(
      id: _newId(),
      type: ContentBlock.typeImage,
      text: text,
      path: path,
    );
  }
  bool get isImage => type == ContentBlock.typeImage;
  bool get isText => type == ContentBlock.typeText;
  void dispose() => textController.dispose();
  static String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${UniqueKey()}';
}
