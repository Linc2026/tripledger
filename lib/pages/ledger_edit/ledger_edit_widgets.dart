import 'package:flutter/material.dart';
import 'package:get/get.dart';
class LedgerEditSourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const LedgerEditSourceTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F5F3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF1A3C34)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class LedgerEditSheetScaffold extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const LedgerEditSheetScaffold({
    super.key,
    this.title,
    required this.children,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EBE9),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
Future<T?> showLedgerEditSheet<T>(Widget child) {
  return Get.bottomSheet<T>(
    child,
    backgroundColor: Colors.transparent,
  );
}
class LedgerEditDraftDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onDiscard;
  const LedgerEditDraftDialog({
    super.key,
    required this.onResume,
    required this.onDiscard,
  });
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F5F3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                size: 28,
                color: Color(0xFF1A3C34),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Resume your draft?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have an unfinished journal. Would you like to continue editing it?',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogBtn(
                    label: 'Discard',
                    bg: const Color(0xFFF2F5F3),
                    fg: const Color(0xFF6B7280),
                    onTap: onDiscard,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogBtn(
                    label: 'Resume',
                    bg: const Color(0xFF1A3C34),
                    fg: Colors.white,
                    onTap: onResume,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class LedgerEditDiscardDialog extends StatelessWidget {
  final VoidCallback onDiscard;
  final VoidCallback onKeep;
  const LedgerEditDiscardDialog({
    super.key,
    required this.onDiscard,
    required this.onKeep,
  });
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Discard changes?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your unsaved changes will be lost.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogBtn(
                    label: 'Keep Editing',
                    bg: const Color(0xFFF2F5F3),
                    fg: const Color(0xFF1A1A1A),
                    onTap: onKeep,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogBtn(
                    label: 'Discard',
                    bg: const Color(0xFFD94F4F),
                    fg: Colors.white,
                    onTap: onDiscard,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class LedgerEditSavedDialog extends StatelessWidget {
  final String summary;
  final VoidCallback onShare;
  final VoidCallback onDone;
  const LedgerEditSavedDialog({
    super.key,
    required this.summary,
    required this.onShare,
    required this.onDone,
  });
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5EE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 28,
                color: Color(0xFF2F9E6A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Journal saved',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              summary,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogBtn(
                    label: 'Share',
                    bg: const Color(0xFFF2F5F3),
                    fg: const Color(0xFF1A3C34),
                    onTap: onShare,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogBtn(
                    label: 'Done',
                    bg: const Color(0xFF1A3C34),
                    fg: Colors.white,
                    onTap: onDone,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class LedgerEditConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  const LedgerEditConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
  });
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogBtn(
                    label: 'Cancel',
                    bg: const Color(0xFFF2F5F3),
                    fg: const Color(0xFF6B7280),
                    onTap: onCancel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogBtn(
                    label: confirmLabel,
                    bg: const Color(0xFF1A3C34),
                    fg: Colors.white,
                    onTap: onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class LedgerEditInputDialog extends StatelessWidget {
  final String title;
  final String hintText;
  final String initialValue;
  final int maxLength;
  final ValueChanged<String> onSubmit;
  final VoidCallback onCancel;
  const LedgerEditInputDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.initialValue,
    required this.maxLength,
    required this.onSubmit,
    required this.onCancel,
  });
  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLength: maxLength,
              autofocus: true,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF2F5F3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DialogBtn(
                    label: 'Cancel',
                    bg: const Color(0xFFF2F5F3),
                    fg: const Color(0xFF6B7280),
                    onTap: onCancel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogBtn(
                    label: 'Save',
                    bg: const Color(0xFF1A3C34),
                    fg: Colors.white,
                    onTap: () => onSubmit(controller.text.trim()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class _DialogBtn extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  const _DialogBtn({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
