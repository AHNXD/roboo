import 'package:flutter/material.dart';

/// Makes a full-height status widget pull-to-refreshable without moving it.
///
/// The home and courses tabs live inside `MainScreen`'s `IndexedStack`, so they
/// are built once and never rebuilt: without this, a request that fails at
/// launch leaves the tab stuck on its error until the app restarts.
class RefreshableStatus extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const RefreshableStatus({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // Always scrollable, otherwise a short child cannot be pulled.
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
