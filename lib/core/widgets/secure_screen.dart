import 'package:flutter/material.dart';

import '../utils/functions.dart';

/// Blocks screenshots and screen recording while its subtree is on screen, and
/// restores normal capture when it leaves.
///
/// Screen protection is a single global window flag, so it is reference
/// counted: nesting two secure screens (a lesson, then the player's own
/// fullscreen route) must not let the inner one re-enable capture while the
/// outer is still showing paid content. Release only lifts the flag when the
/// last secure screen is gone.
///
/// Platforms differ in what they can promise. Android sets `FLAG_SECURE`, which
/// blocks both screenshots and recording outright. iOS has no equivalent, so
/// the plugin uses a protected layer that blanks the captured output — good in
/// practice, but not a guarantee, and neither platform can stop someone
/// pointing a second camera at the screen.
class SecureScreen extends StatefulWidget {
  final Widget child;

  const SecureScreen({super.key, required this.child});

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  static int _activeCount = 0;

  /// Guards against a double release if this state is disposed twice.
  bool _holdsLock = false;

  @override
  void initState() {
    super.initState();
    _acquire();
  }

  @override
  void dispose() {
    // dispose runs on every exit path — pop, back gesture, tab switch, route
    // replacement — which is why the lock lives here and not in a callback on
    // any one button.
    _release();
    super.dispose();
  }

  void _acquire() {
    if (_holdsLock) return;

    _holdsLock = true;
    _activeCount++;
    if (_activeCount == 1) disableScreenshot();
  }

  void _release() {
    if (!_holdsLock) return;

    _holdsLock = false;
    _activeCount--;
    if (_activeCount <= 0) {
      _activeCount = 0;
      enableScreenshot();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
