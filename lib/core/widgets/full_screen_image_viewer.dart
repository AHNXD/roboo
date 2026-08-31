import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-screen viewer for API images: pinch/double-tap to zoom, swipe between
/// the images of a gallery. Uses `InteractiveViewer` and `PageView`, so it needs
/// no extra package.
class FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  /// Opens the viewer. Silently does nothing when there is no image to show, so
  /// callers can hand it whatever the API gave them.
  static Future<void> show(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
  }) {
    final images = imageUrls
        .where((url) => url.trim().isNotEmpty)
        .toList(growable: false);
    if (images.isEmpty) return Future<void>.value();

    // Blanks are dropped, so the tapped index has to be re-mapped onto the
    // filtered list or the viewer opens on the wrong picture.
    final blanksBefore = imageUrls
        .take(initialIndex.clamp(0, imageUrls.length))
        .where((url) => url.trim().isEmpty)
        .length;
    final startIndex = (initialIndex - blanksBefore).clamp(
      0,
      images.length - 1,
    );

    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, _, _) =>
            FullScreenImageViewer(imageUrls: images, initialIndex: startIndex),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  /// One controller per page, so zooming an image and swiping away resets it.
  final Map<int, TransformationController> _zoomControllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _zoomControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TransformationController _zoomFor(int index) {
    return _zoomControllers.putIfAbsent(index, TransformationController.new);
  }

  void _toggleZoom(int index) {
    final controller = _zoomFor(index);
    final isZoomed = controller.value.getMaxScaleOnAxis() > 1.01;
    controller.value = isZoomed
        ? Matrix4.identity()
        : (Matrix4.identity()..scaleByDouble(2.5, 2.5, 2.5, 1));
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.imageUrls.length > 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              // Reset the previous page's zoom so it is not still magnified
              // when the user swipes back.
              _zoomFor(_currentIndex).value = Matrix4.identity();
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onDoubleTap: () => _toggleZoom(index),
                child: InteractiveViewer(
                  transformationController: _zoomFor(index),
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrls[index],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white54,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          if (hasMultiple)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.imageUrls.length}',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
