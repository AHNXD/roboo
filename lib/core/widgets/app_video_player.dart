import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

import '../utils/app_localizations.dart';
import '../utils/colors.dart';
import '../utils/hls_variants.dart';

/// Plays one HLS stream from the API. Both `video_url` and
/// `bunny_video_hls_url` are the same signed Bunny `.m3u8` playlist, which
/// ExoPlayer and AVPlayer both handle natively.
///
/// The url is signed and expires, so a stream that played earlier in the
/// session can still fail later — every failure is surfaced with a retry
/// rather than left as a black rectangle.
class AppVideoPlayer extends StatefulWidget {
  final String url;

  /// Shown while the stream initialises, instead of a black rectangle.
  final String? thumbnailUrl;

  final bool autoPlay;

  /// Fired once, the first time playback reaches the end.
  final VoidCallback? onCompleted;

  /// Fired when the stream fails to open. The urls are signed with a two-hour
  /// expiry counted from when the API response was built, so a screen left
  /// open and resumed later holds a stale url — the owner can refetch and hand
  /// down a fresh one rather than showing the student an error.
  final VoidCallback? onFailed;

  const AppVideoPlayer({
    super.key,
    required this.url,
    this.thumbnailUrl,
    this.autoPlay = true,
    this.onCompleted,
    this.onFailed,
  });

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? _errorMsg;
  bool _completionReported = false;

  List<HlsVariant> _variants = const [];

  /// Null means automatic — the player picks a rendition from the master
  /// playlist as bandwidth allows.
  HlsVariant? _selectedVariant;

  /// Kept across a quality switch so the student does not lose their place.
  Duration _resumeFrom = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _disposeControllers();
      _completionReported = false;
      _errorMsg = null;
      _initialize();
    }
  }

  Future<void> _initialize() async {
    final videoController = VideoPlayerController.networkUrl(
      Uri.parse(_selectedVariant?.url ?? widget.url),
    );
    _videoController = videoController;

    try {
      await videoController.initialize();
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMsg = "video_load_error");
      widget.onFailed?.call();
      return;
    }

    if (!mounted) {
      videoController.dispose();
      return;
    }

    videoController.addListener(_onPlaybackTick);

    if (_resumeFrom > Duration.zero) {
      await videoController.seekTo(_resumeFrom);
      _resumeFrom = Duration.zero;
    }

    // Read once per stream, not per switch: the renditions do not change.
    if (_variants.isEmpty && _selectedVariant == null) {
      unawaited(_loadVariants());
    }

    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: widget.autoPlay,
        looping: false,
        allowPlaybackSpeedChanging: true,
        aspectRatio: videoController.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryColors,
          handleColor: AppColors.primaryColors,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white38,
        ),
        errorBuilder: (context, _) => _message("video_load_error".tr(context)),
        additionalOptions: _variants.isEmpty ? null : _qualityOptions,
      );
    });
  }

  Future<void> _loadVariants() async {
    final variants = await HlsVariantReader().variantsOf(widget.url);
    if (!mounted || variants.length < 2) return;

    // Rebuild so the options menu picks them up.
    setState(() => _variants = variants);
    _rebuildChewie();
  }

  /// The quality menu, offered through Chewie's own options sheet so it sits
  /// with playback speed rather than as a competing control.
  List<OptionItem> _qualityOptions(BuildContext context) {
    final auto = OptionItem(
      onTap: (_) => _switchTo(null),
      iconData: _selectedVariant == null ? Icons.check : Icons.hd_outlined,
      title: "video_quality_auto".tr(context),
    );

    return [
      auto,
      ..._variants.map(
        (variant) => OptionItem(
          onTap: (_) => _switchTo(variant),
          iconData: _selectedVariant?.height == variant.height
              ? Icons.check
              : Icons.hd_outlined,
          title: variant.label,
        ),
      ),
    ];
  }

  /// Re-opens the stream on the chosen rendition, resuming where it was.
  Future<void> _switchTo(HlsVariant? variant) async {
    if (_selectedVariant?.url == variant?.url) return;

    _resumeFrom = _videoController?.value.position ?? Duration.zero;
    _selectedVariant = variant;

    _disposeControllers();
    if (!mounted) return;

    setState(() => _errorMsg = null);
    await _initialize();
  }

  void _rebuildChewie() {
    final videoController = _videoController;
    if (videoController == null || !mounted) return;

    final previous = _chewieController;
    setState(() {
      _chewieController = previous?.copyWith(
        additionalOptions: _variants.isEmpty ? null : _qualityOptions,
      );
    });
    // The copy reuses the same video controller, so the old wrapper is dropped
    // without disposing what is still playing.
  }

  void _onPlaybackTick() {
    final value = _videoController?.value;
    if (value == null || _completionReported) return;

    // `isCompleted` is only set once the position actually reaches the end, so
    // it does not fire on a seek to the last frame.
    if (value.isCompleted) {
      _completionReported = true;
      widget.onCompleted?.call();
    }
  }

  void _disposeControllers() {
    _videoController?.removeListener(_onPlaybackTick);
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _retry() {
    _disposeControllers();
    setState(() => _errorMsg = null);
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMsg != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _message(_errorMsg!.tr(context)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _retry,
                child: Text(
                  "retry".tr(context),
                  style: GoogleFonts.cairo(
                    color: AppColors.primaryColors,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final chewieController = _chewieController;
    if (chewieController == null) {
      final thumbnail = widget.thumbnailUrl;

      return Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (thumbnail != null && thumbnail.trim().isNotEmpty)
              Image.network(
                thumbnail,
                fit: BoxFit.contain,
                // A poster that fails to load is not worth reporting; the
                // stream itself is what matters.
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Chewie(controller: chewieController),
    );
  }

  Widget _message(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(color: Colors.white),
      ),
    );
  }
}
