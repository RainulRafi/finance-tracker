import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: context.colors.muted,
      ),
    );
  }
}

InputDecoration appInputDecoration(
  BuildContext context, {
  String? hint,
  String? prefix,
}) {
  final c = context.colors;
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: c.subtle),
    prefixText: prefix,
    prefixStyle: TextStyle(color: c.ink, fontWeight: FontWeight.w600),
    filled: true,
    fillColor: c.field,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}
