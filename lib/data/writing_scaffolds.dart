class WritingScaffold {
  final String title;
  final String body;
  const WritingScaffold({required this.title, required this.body});
}
const kWritingScaffolds = <WritingScaffold>[
  WritingScaffold(
    title: 'Day by Day',
    body: '''Day 1:
-
Day 2:
-
Highlights:
-''',
  ),
  WritingScaffold(
    title: 'Food & Places',
    body: '''Must-try food:
-
Favorite places:
-
Local tips:
-''',
  ),
  WritingScaffold(
    title: 'Highlights',
    body: '''Best moment:
-
Unexpected surprise:
-
Would I go again?
-''',
  ),
];
const kMoodOptions = <String>[
  'Happy',
  'Excited',
  'Peaceful',
  'Tired',
  'Grateful',
];
const kTemplateSlotSuffix = '\n\nDestination: {{place}}\nBest memory: {{highlight}}';
final _slotPattern = RegExp(r'\{\{(\w+)\}\}');
List<String> extractTemplateSlots(String text) {
  return _slotPattern
      .allMatches(text)
      .map((m) => m.group(1)!)
      .toSet()
      .toList();
}
String replaceTemplateSlot(String text, String slot, String value) {
  return text.replaceAll('{{$slot}}', value);
}
String? resolveWritingPrompt({
  required String content,
  required String tripStartDate,
  required String tripEndDate,
  required String mood,
  required bool hasPhotos,
}) {
  final trimmed = content.trim();
  final lower = trimmed.toLowerCase();
  if (trimmed.isEmpty) {
    if (tripStartDate.isNotEmpty) {
      return 'What happened on day 1 of your trip?';
    }
    return 'What was the highlight of this journey?';
  }
  if (trimmed.length < 80) {
    return 'Add one sensory detail — a sound, smell, or color.';
  }
  if (lower.contains('food') ||
      lower.contains('restaurant') ||
      lower.contains('eat') ||
      lower.contains('dish')) {
    return 'Any dish you would recommend to a friend?';
  }
  if (hasPhotos && trimmed.length < 220) {
    return 'Describe the story behind one of your photos.';
  }
  if (tripEndDate.isNotEmpty &&
      !lower.contains('last day') &&
      !lower.contains('return')) {
    return 'How did you feel on the last day?';
  }
  if (mood == 'Tired') {
    return 'What made the trip worth the fatigue?';
  }
  if (trimmed.length < 400) {
    return 'What would you do differently next time?';
  }
  return null;
}
