class ScanSummary {
  final String id;
  final String imageUrl;
  final String diagnosisName;
  final int severityScore;
  final double confidence;
  final DateTime createdAt;

  ScanSummary({
    required this.id,
    required this.imageUrl,
    required this.diagnosisName,
    required this.severityScore,
    required this.confidence,
    required this.createdAt,
  });

  factory ScanSummary.fromJson(Map<String, dynamic> json) {
    return ScanSummary(
      id: json['id'],
      imageUrl: json['image_url'],
      diagnosisName: json['diagnosis_name'],
      severityScore: json['severity_score'],
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}