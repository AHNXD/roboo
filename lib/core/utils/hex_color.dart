import 'package:flutter/material.dart';

/// Parses a colour the dashboard stores as a hex string — `#333333`, `333333`,
/// or with an alpha pair in front. Returns null for anything unparseable,
/// including the `null` most topics and categories still have, so callers keep
/// their own default rather than falling back to an arbitrary colour.
Color? colorFromHex(String? hex) {
  final value = hex?.trim().replaceAll('#', '');
  if (value == null || value.isEmpty) return null;

  final normalized = switch (value.length) {
    6 => 'FF$value',
    8 => value,
    // `#abc` shorthand, expanded to full pairs.
    3 => 'FF${value[0] * 2}${value[1] * 2}${value[2] * 2}',
    _ => null,
  };
  if (normalized == null) return null;

  final parsed = int.tryParse(normalized, radix: 16);
  return parsed == null ? null : Color(parsed);
}
