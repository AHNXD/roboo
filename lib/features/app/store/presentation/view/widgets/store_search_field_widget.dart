import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';

/// Owns its own controller so the text survives the rebuilds that every search
/// result triggers.
class StoreSearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onCleared;

  const StoreSearchField({
    super.key,
    required this.onChanged,
    required this.onCleared,
  });

  @override
  State<StoreSearchField> createState() => _StoreSearchFieldState();
}

class _StoreSearchFieldState extends State<StoreSearchField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final hasText = value.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);

    widget.onChanged(value);
  }

  void _clear() {
    _controller.clear();
    setState(() => _hasText = false);
    FocusScope.of(context).unfocus();
    widget.onCleared();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.cairo(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          hintText: "search_products_hint".tr(context),
          hintStyle: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.primaryColors,
            size: 20,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  onPressed: _clear,
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  tooltip: "clear_search".tr(context),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.secColors),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.secColors),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.primaryColors,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
