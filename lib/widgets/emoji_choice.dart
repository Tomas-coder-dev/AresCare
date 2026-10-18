import 'package:characters/characters.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Suggested emojis, with a plus that opens a small field for one more.
class EmojiChoice extends StatefulWidget {
  const EmojiChoice({
    required this.emojis,
    required this.selected,
    required this.onSelected,
    this.fieldKey,
    this.addKey,
    super.key,
  });

  final List<String> emojis;
  final String selected;
  final ValueChanged<String> onSelected;
  final Key? fieldKey;
  final Key? addKey;

  @override
  State<EmojiChoice> createState() => _EmojiChoiceState();
}

class _EmojiChoiceState extends State<EmojiChoice> {
  late final TextEditingController _custom;
  late final FocusNode _focus;
  bool _open = false;
  bool _fromField = false;

  @override
  void initState() {
    super.initState();
    _custom = TextEditingController();
    _focus = FocusNode();
  }

  bool get _customSelected => !widget.emojis.contains(widget.selected);

  @override
  void didUpdateWidget(EmojiChoice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected == oldWidget.selected || _fromField) {
      _fromField = false;
      return;
    }
    if (!_customSelected) {
      _custom.clear();
      _open = false;
    }
  }

  @override
  void dispose() {
    _custom.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _openField() {
    setState(() => _open = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focus.requestFocus();
      }
    });
  }

  void _pickListed(String emoji) {
    _custom.clear();
    setState(() => _open = false);
    widget.onSelected(emoji);
  }

  void _typeCustom(String raw) {
    final graphemes = raw.trim().characters;
    if (graphemes.isEmpty) {
      return;
    }
    _fromField = true;
    widget.onSelected(graphemes.first);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final emoji in widget.emojis)
          _EmojiBubble(
            emoji: emoji,
            selected: widget.selected == emoji,
            onTap: () => _pickListed(emoji),
          ),
        if (_customSelected && !_open)
          _EmojiBubble(
            emoji: widget.selected,
            selected: true,
            onTap: _openField,
          ),
        if (_open)
          _CustomSlot(
            fieldKey: widget.fieldKey,
            controller: _custom,
            focusNode: _focus,
            filled: _customSelected,
            onChanged: _typeCustom,
          )
        else
          _PlusBubble(key: widget.addKey, onTap: _openField),
      ],
    );
  }
}

class _EmojiBubble extends StatelessWidget {
  const _EmojiBubble({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryText.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}

class _PlusBubble extends StatelessWidget {
  const _PlusBubble({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accent, width: 1.4),
        ),
        child: const Icon(
          Icons.add_rounded,
          color: AppColors.primaryText,
          size: 22,
        ),
      ),
    );
  }
}

class _CustomSlot extends StatelessWidget {
  const _CustomSlot({
    required this.controller,
    required this.focusNode,
    required this.filled,
    required this.onChanged,
    this.fieldKey,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool filled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 42,
      child: TextField(
        key: fieldKey,
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, height: 1),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: filled ? AppColors.accent : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(21),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(21),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(21),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
