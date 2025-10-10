class AppiItem {
  final String id;
  final String title;
  final String? description;
  final String? imageId; // campo original de la API
  final String? imageUrl; // URL pública (IIIF) o thumbnail lqip
  final String? artistDisplay;
  final String? placeOfOrigin;
  final String? dateDisplay;

  AppiItem({
    required this.id,
    required this.title,
    this.description,
    this.imageId,
    this.imageUrl,
    this.artistDisplay,
    this.placeOfOrigin,
    this.dateDisplay,
  });

  /// Construye la URL IIIF a partir de image_id si es posible.
  static String? buildIiifUrl(String? imageId, {int width = 800}) {
    if (imageId == null) return null;
    return 'https://www.artic.edu/iiif/2/$imageId/full/$width,/0/default.jpg';
  }

  factory AppiItem.fromJson(Map<String, dynamic> json) {
    final String id = (json['id'] ?? json['ID'] ?? '').toString();
    final String title = (json['title'] ?? json['name'] ?? 'Sin título').toString();

    String? description = json['description'] as String?;
    description ??= json['short_description'] as String?;
    // Sanear HTML básico
    description = _stripHtml(description);

    String? imageId = json['image_id'] as String?;

    String? thumbnailLqip;
    try {
      final thumb = json['thumbnail'] as Map<String, dynamic>?;
      thumbnailLqip = thumb != null ? (thumb['lqip'] as String?) : null;
    } catch (_) {
      thumbnailLqip = null;
    }

    final String? iiif = buildIiifUrl(imageId);

    final String? artistDisplay = json['artist_display'] as String?;
    final String? placeOfOrigin = json['place_of_origin'] as String?;
    final String? dateDisplay = json['date_display'] as String?;

    return AppiItem(
      id: id,
      title: title,
      description: description,
      imageId: imageId,
      imageUrl: iiif ?? thumbnailLqip,
      artistDisplay: artistDisplay,
      placeOfOrigin: placeOfOrigin,
      dateDisplay: dateDisplay,
    );
  }

  static String? _stripHtml(String? input) {
    if (input == null) return null;
    // Eliminar tags HTML simples y entidades básicas
    String out = input.replaceAll(RegExp(r'<[^>]*>'), '');
    out = out.replaceAll('&nbsp;', ' ');
    out = out.replaceAll('&amp;', '&');
    out = out.replaceAll('&lt;', '<');
    out = out.replaceAll('&gt;', '>');
    return out.trim();
  }
}
