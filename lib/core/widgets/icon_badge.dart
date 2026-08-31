import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/colors.dart';

/// A count bubble over an icon — the cart's items, the bell's unread
/// notifications.
///
/// Shows nothing at zero rather than a "0", caps at 99+ so a large number
/// cannot stretch the bubble across the icon, and falls back to a plain dot
/// when the count is not known yet (the request is still in flight) — a dot
/// still says "there is something here" without inventing a number.
class IconBadge extends StatelessWidget {
  final Widget child;

  /// Null means "something is there, but the count is unknown".
  final int? count;

  /// False hides the badge entirely.
  final bool isVisible;

  const IconBadge({
    super.key,
    required this.child,
    required this.count,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    final value = count ?? 0;
    if (!isVisible || (count != null && value <= 0)) return child;

    final label = value > 99 ? '99+' : '$value';
    final isDot = count == null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(
          top: 4,
          end: 4,
          child: Container(
            padding: isDot
                ? const EdgeInsets.all(4)
                : const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            constraints: const BoxConstraints(minWidth: 18),
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(10),
              // Separates the bubble from whatever it sits on.
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: isDot
                ? const SizedBox.shrink()
                : Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
