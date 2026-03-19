import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSvgPainterWidget extends StatefulWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  /// The specific color in the SVG that should be inverted.
  ///
  /// For example, if you pass [Colors.black], then any black path in the SVG
  /// will be rendered as white (mathematical inversion).
  final Color? colorToInvert;

  const CustomSvgPainterWidget({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.colorToInvert,
  });

  @override
  State<CustomSvgPainterWidget> createState() => _CustomSvgPainterWidgetState();
}

class _CustomSvgPainterWidgetState extends State<CustomSvgPainterWidget> {
  Future<PictureInfo>? _svgFuture;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  @override
  void didUpdateWidget(covariant CustomSvgPainterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.assetPath != oldWidget.assetPath ||
        widget.colorToInvert != oldWidget.colorToInvert) {
      _loadSvg();
    }
  }

  void _loadSvg() {
    const SvgTheme theme = SvgTheme();
    _svgFuture = vg.loadPicture(
      SvgAssetLoader(
        widget.assetPath,
        theme: theme,
        colorMapper: widget.colorToInvert != null
            ? SelectiveColorMapper(widget.colorToInvert!)
            : null,
      ),
      null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PictureInfo>(
      future: _svgFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final Size pictureSize = snapshot.data!.size;
          double? width = widget.width;
          double? height = widget.height;

          if (width == null && height != null) {
            width = height * (pictureSize.width / pictureSize.height);
          } else if (height == null && width != null) {
            height = width * (pictureSize.height / pictureSize.width);
          }

          if (width == null && height == null) {
            width = pictureSize.width;
            height = pictureSize.height;
          }

          return SizedBox(
            width: width,
            height: height,
            child: CustomPaint(
              size: Size(
                width ?? pictureSize.width,
                height ?? pictureSize.height,
              ),
              painter: _SvgPainter(
                snapshot.data!,
                color: widget.color,
                fit: widget.fit,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SvgPainter extends CustomPainter {
  final PictureInfo pictureInfo;
  final Color? color;
  final BoxFit fit;

  _SvgPainter(this.pictureInfo, {this.color, required this.fit});

  @override
  void paint(Canvas canvas, Size size) {
    // If a color is provided, we can apply a color filter to the layer
    if (color != null) {
      final paint = Paint()
        ..colorFilter = ColorFilter.mode(color!, BlendMode.srcIn);
      canvas.saveLayer(Offset.zero & size, paint);
    }

    // Calculate scale to fit/cover the available size
    // pictureInfo.size is the viewport size of the SVG
    final double scaleX = size.width / pictureInfo.size.width;
    final double scaleY = size.height / pictureInfo.size.height;

    double scale = 1.0;
    double dx = 0.0;
    double dy = 0.0;

    switch (fit) {
      case BoxFit.contain:
        scale = scaleX < scaleY ? scaleX : scaleY;
        dx = (size.width - pictureInfo.size.width * scale) / 2;
        dy = (size.height - pictureInfo.size.height * scale) / 2;
        break;
      case BoxFit.cover:
        scale = scaleX > scaleY ? scaleX : scaleY;
        dx = (size.width - pictureInfo.size.width * scale) / 2;
        dy = (size.height - pictureInfo.size.height * scale) / 2;
        break;
      case BoxFit.fill:
        canvas.scale(scaleX, scaleY);
        canvas.drawPicture(pictureInfo.picture);
        if (color != null) canvas.restore();
        return;
      case BoxFit.none:
        scale = 1.0;
        dx = (size.width - pictureInfo.size.width) / 2;
        dy = (size.height - pictureInfo.size.height) / 2;
        break;
      case BoxFit.fitWidth:
        scale = scaleX;
        dy = (size.height - pictureInfo.size.height * scale) / 2;
        break;
      case BoxFit.fitHeight:
        scale = scaleY;
        dx = (size.width - pictureInfo.size.width * scale) / 2;
        break;
      case BoxFit.scaleDown:
        scale = scaleX < scaleY ? scaleX : scaleY;
        if (scale > 1.0) scale = 1.0;
        dx = (size.width - pictureInfo.size.width * scale) / 2;
        dy = (size.height - pictureInfo.size.height * scale) / 2;
        break;
    }

    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    canvas.drawPicture(pictureInfo.picture);

    if (color != null) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SvgPainter oldDelegate) {
    return oldDelegate.pictureInfo != pictureInfo || oldDelegate.color != color;
  }
}

class SelectiveColorMapper extends ColorMapper {
  final Color targetColor;

  const SelectiveColorMapper(this.targetColor);

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color.value == targetColor.value) {
      // Invert the color (255 - component)
      return Color.fromARGB(
        color.alpha,
        255 - color.red,
        255 - color.green,
        255 - color.blue,
      );
    }
    return color;
  }
}
