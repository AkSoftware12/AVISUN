import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullScreenImageSlider extends StatefulWidget {
  final List<dynamic> images;
  final int initialIndex;

  const FullScreenImageSlider({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  _FullScreenImageSliderState createState() => _FullScreenImageSliderState();
}

class _FullScreenImageSliderState extends State<FullScreenImageSlider> {
  late PageController _pageController;
  int _currentIndex = 0;
  final Map<int, TransformationController> _transformationControllers = {};
  final Map<int, bool> _isZoomed = {};

  @override
  void initState() {
    super.initState();
    // Validate initialIndex
    _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _currentIndex);

    // Initialize transformation controllers and zoom state for each image
    for (int i = 0; i < widget.images.length; i++) {
      _transformationControllers[i] = TransformationController();
      _isZoomed[i] = false;
    }

    // Add listener for page changes
    _pageController.addListener(() {
      final newIndex = _pageController.page?.round() ?? _currentIndex;
      if (newIndex != _currentIndex && mounted) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
    });
  }

  @override
  void didUpdateWidget(FullScreenImageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle changes in images or initialIndex
    if (oldWidget.initialIndex != widget.initialIndex ||
        oldWidget.images != widget.images) {
      _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1);
      _pageController.jumpToPage(_currentIndex);

      // Update transformation controllers and zoom state
      _transformationControllers.clear();
      _isZoomed.clear();
      for (int i = 0; i < widget.images.length; i++) {
        _transformationControllers[i] = TransformationController();
        _isZoomed[i] = false;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Dispose all transformation controllers
    _transformationControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _handleDoubleTap(int index) {
    final controller = _transformationControllers[index]!;
    setState(() {
      if (_isZoomed[index]!) {
        // Zoom out
        controller.value = Matrix4.identity();
        _isZoomed[index] = false;
      } else {
        // Zoom in at center
        final scale = 2.0; // Zoom scale factor
        final size = MediaQuery.of(context).size;
        final centerX = size.width / 2;
        final centerY = size.height / 2;
        final zoomedMatrix = Matrix4.identity()
          ..translate(-centerX * (scale - 1), -centerY * (scale - 1))
          ..scale(scale);
        controller.value = zoomedMatrix;
        _isZoomed[index] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Handle empty images list
    if (widget.images.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            'No images available',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1}/${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              // Validate image data
              final imageData = widget.images[index];
              final imageUrl = imageData is Map && imageData['image_url_full'] != null
                  ? imageData['image_url_full'].toString()
                  : '';

              return GestureDetector(
                onDoubleTap: () => _handleDoubleTap(index),
                child: InteractiveViewer(
                  transformationController: _transformationControllers[index],
                  minScale: 0.5,
                  maxScale: 4.0,
                  boundaryMargin: const EdgeInsets.all(20.0),
                  child: Center(
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error,
                              color: Colors.white,
                              size: 50,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      // Add cache configuration
                      memCacheWidth: MediaQuery.of(context).size.width.toInt() * 2,
                      memCacheHeight: MediaQuery.of(context).size.height.toInt() * 2,
                    )
                        : const Center(
                      child: Text(
                        'Invalid image URL',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Add optional image counter at bottom
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Text(
              '${_currentIndex + 1}/${widget.images.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}