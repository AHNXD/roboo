import 'package:flutter/material.dart';

/// Calls [onLoadMore] when the wrapped scrollable nears its end.
///
/// Wraps the list rather than owning a `ScrollController`, so it works with any
/// scrollable — including the grid in the store — without each screen having to
/// create and dispose a controller.
class LoadMoreListener extends StatelessWidget {
  final Widget child;
  final VoidCallback onLoadMore;

  /// False while a page is already in flight, or once the last page is loaded.
  final bool canLoadMore;

  /// How far from the bottom to fire, in pixels. Roughly a screen of runway, so
  /// the next page is usually there before the user reaches the end.
  final double threshold;

  const LoadMoreListener({
    super.key,
    required this.child,
    required this.onLoadMore,
    required this.canLoadMore,
    this.threshold = 400,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!canLoadMore) return false;

        // Only react to the scrollable this widget wraps, not to a nested one.
        if (notification.depth != 0) return false;

        final metrics = notification.metrics;
        if (!metrics.hasContentDimensions) return false;

        if (metrics.pixels >= metrics.maxScrollExtent - threshold) {
          onLoadMore();
        }

        // Never swallow the notification: other widgets may be listening too.
        return false;
      },
      child: child,
    );
  }
}
