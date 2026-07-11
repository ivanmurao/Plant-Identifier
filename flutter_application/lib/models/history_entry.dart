/// A lightweight local record of a past scan, stored on-device so the
/// history screen can show a list instantly without re-calling the API.
///
/// The [accessToken] is what Kindwise's "Retrieve identification" (GET)
/// endpoint needs if the user wants to reload the full result later —
/// results stay retrievable for 6 months per Kindwise's docs.
class HistoryEntry {
  final String accessToken;
  final String imagePath;
  final String plantName;
  final String? commonName;
  final double probability;
  final DateTime scannedAt;

  const HistoryEntry({
    required this.accessToken,
    required this.imagePath,
    required this.plantName,
    this.commonName,
    required this.probability,
    required this.scannedAt,
  });

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'image_path': imagePath,
        'plant_name': plantName,
        'common_name': commonName,
        'probability': probability,
        'scanned_at': scannedAt.toIso8601String(),
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      accessToken: json['access_token'] ?? '',
      imagePath: json['image_path'] ?? '',
      plantName: json['plant_name'] ?? 'Unknown plant',
      commonName: json['common_name'],
      probability: (json['probability'] ?? 0).toDouble(),
      scannedAt: DateTime.tryParse(json['scanned_at'] ?? '') ?? DateTime.now(),
    );
  }
}