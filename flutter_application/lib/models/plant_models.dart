// ─────────────────────────────────────────────────────────────────────────────
// PlantNet API – Response Models
// ─────────────────────────────────────────────────────────────────────────────

class PlantNetResponse {
  final PlantNetQuery query;
  final List<PlantResult> results;
  final int remainingIdentificationRequests;
  final String? language;

  const PlantNetResponse({
    required this.query,
    required this.results,
    required this.remainingIdentificationRequests,
    this.language,
  });

  factory PlantNetResponse.fromJson(Map<String, dynamic> json) {
    return PlantNetResponse(
      query: PlantNetQuery.fromJson(json['query'] as Map<String, dynamic>),
      results: (json['results'] as List<dynamic>)
          .map((e) => PlantResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      remainingIdentificationRequests:
          json['remainingIdentificationRequests'] as int? ?? 0,
      language: json['language'] as String?,
    );
  }

  /// Best match (highest score)
  PlantResult? get topResult => results.isNotEmpty ? results.first : null;
}

// ── Query ──────────────────────────────────────────────────────────────────

class PlantNetQuery {
  final String project;
  final List<String> images;
  final List<String> organs;

  const PlantNetQuery({
    required this.project,
    required this.images,
    required this.organs,
  });

  factory PlantNetQuery.fromJson(Map<String, dynamic> json) {
    return PlantNetQuery(
      project: json['project'] as String? ?? '',
      images: List<String>.from(json['images'] as List<dynamic>? ?? []),
      organs: List<String>.from(json['organs'] as List<dynamic>? ?? []),
    );
  }
}

// ── Result ─────────────────────────────────────────────────────────────────

class PlantResult {
  final double score;
  final Species species;

  const PlantResult({required this.score, required this.species});

  factory PlantResult.fromJson(Map<String, dynamic> json) {
    return PlantResult(
      score: (json['score'] as num).toDouble(),
      species: Species.fromJson(json['species'] as Map<String, dynamic>),
    );
  }

  /// Score as a percentage string, e.g. "99.5%"
  String get scorePercent => '${(score * 100).toStringAsFixed(1)}%';

  /// Confidence tier based on score
  ConfidenceTier get confidenceTier {
    if (score >= 0.7) return ConfidenceTier.high;
    if (score >= 0.4) return ConfidenceTier.medium;
    return ConfidenceTier.low;
  }
}

enum ConfidenceTier { high, medium, low }

// ── Species ────────────────────────────────────────────────────────────────

class Species {
  final String scientificNameWithoutAuthor;
  final String scientificNameAuthorship;
  final TaxonInfo genus;
  final TaxonInfo family;
  final List<String> commonNames;

  const Species({
    required this.scientificNameWithoutAuthor,
    required this.scientificNameAuthorship,
    required this.genus,
    required this.family,
    required this.commonNames,
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      scientificNameWithoutAuthor:
          json['scientificNameWithoutAuthor'] as String? ?? '',
      scientificNameAuthorship:
          json['scientificNameAuthorship'] as String? ?? '',
      genus: TaxonInfo.fromJson(
          json['genus'] as Map<String, dynamic>? ?? {}),
      family: TaxonInfo.fromJson(
          json['family'] as Map<String, dynamic>? ?? {}),
      commonNames: List<String>.from(
          json['commonNames'] as List<dynamic>? ?? []),
    );
  }

  /// Full scientific name with authorship
  String get fullScientificName =>
      '$scientificNameWithoutAuthor $scientificNameAuthorship'.trim();

  /// Primary common name (or scientific name if none available)
  String get primaryCommonName =>
      commonNames.isNotEmpty ? commonNames.first : scientificNameWithoutAuthor;
}

// ── Taxon ──────────────────────────────────────────────────────────────────

class TaxonInfo {
  final String scientificNameWithoutAuthor;
  final String scientificNameAuthorship;

  const TaxonInfo({
    required this.scientificNameWithoutAuthor,
    required this.scientificNameAuthorship,
  });

  factory TaxonInfo.fromJson(Map<String, dynamic> json) {
    return TaxonInfo(
      scientificNameWithoutAuthor:
          json['scientificNameWithoutAuthor'] as String? ?? '',
      scientificNameAuthorship:
          json['scientificNameAuthorship'] as String? ?? '',
    );
  }
}

// ── Organ type for image labelling ─────────────────────────────────────────

enum PlantOrgan {
  auto,
  flower,
  leaf,
  fruit,
  bark,
  habit,
  other;

  String get label {
    switch (this) {
      case PlantOrgan.auto:   return 'auto';
      case PlantOrgan.flower: return 'flower';
      case PlantOrgan.leaf:   return 'leaf';
      case PlantOrgan.fruit:  return 'fruit';
      case PlantOrgan.bark:   return 'bark';
      case PlantOrgan.habit:  return 'habit';
      case PlantOrgan.other:  return 'other';
    }
  }

  String get displayName {
    switch (this) {
      case PlantOrgan.auto:   return 'Auto-detect';
      case PlantOrgan.flower: return 'Flower';
      case PlantOrgan.leaf:   return 'Leaf';
      case PlantOrgan.fruit:  return 'Fruit';
      case PlantOrgan.bark:   return 'Bark';
      case PlantOrgan.habit:  return 'Full plant';
      case PlantOrgan.other:  return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case PlantOrgan.auto:   return '🔍';
      case PlantOrgan.flower: return '🌸';
      case PlantOrgan.leaf:   return '🍃';
      case PlantOrgan.fruit:  return '🍎';
      case PlantOrgan.bark:   return '🪵';
      case PlantOrgan.habit:  return '🌿';
      case PlantOrgan.other:  return '📷';
    }
  }
}

// ── Image entry (image + organ label) ─────────────────────────────────────

class ImageEntry {
  final String filePath;
  PlantOrgan organ;

  ImageEntry({required this.filePath, this.organ = PlantOrgan.auto});
}
