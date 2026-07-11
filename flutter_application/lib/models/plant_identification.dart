/// Parsed representation of a single plant suggestion returned by the
/// Plant.id (Kindwise) v3 `/identification` endpoint.
class PlantIdentification {
  final String accessToken;
  final bool isPlant;
  final double isPlantProbability;

  final String scientificName;
  final double probability;
  final List<String> commonNames;
  final String? description;
  final String? wikiUrl;
  final String? representativeImageUrl;
  final Map<String, dynamic>? taxonomy;
  final List<String>? ediblePartsList;
  final String? bestWatering;
  final String? bestLightCondition;
  final String? bestSoilType;
  final String? toxicity;
  final String? culturalSignificance;

  PlantIdentification({
    required this.accessToken,
    required this.isPlant,
    required this.isPlantProbability,
    required this.scientificName,
    required this.probability,
    required this.commonNames,
    this.description,
    this.wikiUrl,
    this.representativeImageUrl,
    this.taxonomy,
    this.ediblePartsList,
    this.bestWatering,
    this.bestLightCondition,
    this.bestSoilType,
    this.toxicity,
    this.culturalSignificance,
  });

  /// A safe helper to extract text whether the API returns a raw string
  /// or a dictionary/map containing a "value" key.
  static String? _extractStringDetail(dynamic detail) {
    if (detail == null) return null;
    if (detail is String) return detail;
    if (detail is Map<String, dynamic>) {
      // Safely extract the string if the API wraps it in an object
      return detail['value']?.toString();
    }
    return detail.toString();
  }

  /// Builds a [PlantIdentification] from the raw JSON body of a
  /// Plant.id v3 identification response, taking the top (most probable)
  /// suggestion.
  factory PlantIdentification.fromApiResponse(Map<String, dynamic> json) {
    final accessToken = json['access_token'] as String? ?? '';
    final result = json['result'] as Map<String, dynamic>? ?? {};

    final isPlantBlock = result['is_plant'] as Map<String, dynamic>? ?? {};
    final isPlant = isPlantBlock['binary'] as bool? ?? false;
    final isPlantProbability =
        (isPlantBlock['probability'] as num?)?.toDouble() ?? 0.0;

    final classification =
        result['classification'] as Map<String, dynamic>? ?? {};
    final suggestions = classification['suggestions'] as List<dynamic>? ?? [];

    if (suggestions.isEmpty) {
      return PlantIdentification(
        accessToken: accessToken,
        isPlant: isPlant,
        isPlantProbability: isPlantProbability,
        scientificName: 'Unknown plant',
        probability: 0,
        commonNames: const [],
      );
    }

    final top = suggestions.first as Map<String, dynamic>;
    final details = top['details'] as Map<String, dynamic>? ?? {};

    final rawCommonNames = details['common_names'] as List<dynamic>? ?? [];
    final rawEdibleParts = details['edible_parts'] as List<dynamic>?;

    final descriptionData =
        details['description_all'] ?? details['description'];

    return PlantIdentification(
      accessToken: accessToken,
      isPlant: isPlant,
      isPlantProbability: isPlantProbability,
      scientificName: top['name'] as String? ?? 'Unknown plant',
      probability: (top['probability'] as num?)?.toDouble() ?? 0.0,
      commonNames: rawCommonNames.map((e) => e.toString()).toList(),

      // Use the helper to safely parse API responses that might be Strings OR Maps
      description: _extractStringDetail(descriptionData),
      wikiUrl: _extractStringDetail(details['url']),
      representativeImageUrl: _extractStringDetail(details['image']),
      taxonomy: details['taxonomy'] as Map<String, dynamic>?,
      ediblePartsList: rawEdibleParts?.map((e) => e.toString()).toList(),
      bestWatering: _extractStringDetail(details['best_watering']),
      bestLightCondition: _extractStringDetail(details['best_light_condition']),
      bestSoilType: _extractStringDetail(details['best_soil_type']),
      toxicity: _extractStringDetail(details['toxicity']),
      culturalSignificance: _extractStringDetail(details['cultural_significance']),
    );
  }
}