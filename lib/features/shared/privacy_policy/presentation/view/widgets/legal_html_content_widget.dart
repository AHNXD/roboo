import 'package:flutter/material.dart';

class LegalHtmlContentWidget extends StatelessWidget {
  final String html;
  final String? updatedAt;
  final String updatedAtLabel;

  const LegalHtmlContentWidget({
    super.key,
    required this.html,
    this.updatedAt,
    required this.updatedAtLabel,
  });

  @override
  Widget build(BuildContext context) {
    final paragraphs = _htmlToParagraphs(html);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        ...paragraphs.map(
          (paragraph) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              paragraph,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black54,
              ),
            ),
          ),
        ),
        if (updatedAt?.trim().isNotEmpty == true) ...[
          const Divider(height: 40, color: Colors.grey),
          Text(
            '$updatedAtLabel ${updatedAt!}',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.black45,
            ),
          ),
        ],
      ],
    );
  }

  List<String> _htmlToParagraphs(String source) {
    final withoutScripts = source
        .replaceAll(
          RegExp(
            r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(
          RegExp(
            r'<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>',
            caseSensitive: false,
          ),
          '',
        );

    final withBreaks = withoutScripts
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<li\b[^>]*>', caseSensitive: false), '\n• ')
        .replaceAll(
          RegExp(
            r'</(p|div|h[1-6]|li|ul|ol|blockquote)>',
            caseSensitive: false,
          ),
          '\n\n',
        );

    final plainText = _decodeHtmlEntities(
      withBreaks.replaceAll(RegExp(r'<[^>]+>'), ''),
    );

    return plainText
        .split(RegExp(r'\n{2,}'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  String _decodeHtmlEntities(String text) {
    return text.replaceAllMapped(RegExp(r'&(#x?[0-9a-fA-F]+|\w+);'), (match) {
      final entity = match.group(1) ?? '';
      if (entity.startsWith('#x') || entity.startsWith('#X')) {
        final codePoint = int.tryParse(entity.substring(2), radix: 16);
        return codePoint == null
            ? match.group(0)!
            : String.fromCharCode(codePoint);
      }
      if (entity.startsWith('#')) {
        final codePoint = int.tryParse(entity.substring(1));
        return codePoint == null
            ? match.group(0)!
            : String.fromCharCode(codePoint);
      }

      return switch (entity) {
        'amp' => '&',
        'lt' => '<',
        'gt' => '>',
        'quot' => '"',
        'apos' => "'",
        'nbsp' => ' ',
        _ => match.group(0)!,
      };
    });
  }
}
