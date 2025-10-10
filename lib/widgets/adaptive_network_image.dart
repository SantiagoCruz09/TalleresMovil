import 'package:flutter/material.dart';

/// AdaptiveNetworkImage intenta cargar una lista de URLs en orden y se
/// sustituye por la siguiente URL si la anterior falla.
class AdaptiveNetworkImage extends StatefulWidget {
  final List<String?> sources;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget placeholder;

  const AdaptiveNetworkImage({
    super.key,
    required this.sources,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder = const SizedBox.shrink(),
  });

  @override
  State<AdaptiveNetworkImage> createState() => _AdaptiveNetworkImageState();
}

class _AdaptiveNetworkImageState extends State<AdaptiveNetworkImage> {
  late List<String> _urls;
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    _urls = widget.sources.whereType<String>().toList();
  }

  void _next() {
    if (!mounted) return;
    setState(() {
      _idx++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_idx >= _urls.length) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.placeholder,
      );
    }

    final url = _urls[_idx];
    return Image.network(
      url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        // Intentar siguiente fuente
        WidgetsBinding.instance.addPostFrameCallback((_) => _next());
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: widget.placeholder,
        );
      },
    );
  }
}
