class AnalysisResult {
  final bool isPlant;
  final String? imageUrl;
  final Diagnosis diagnosis;
  final Severity severity;
  final String recommendation;

  AnalysisResult({
    required this.isPlant,
    this.imageUrl,
    required this.diagnosis,
    required this.severity,
    required this.recommendation,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      isPlant: json['is_plant'] ?? false,
      imageUrl: json['image_url'],
      diagnosis: Diagnosis.fromJson(json['diagnosis'] ?? {}),
      severity: Severity.fromJson(json['severity'] ?? {}),
      recommendation: json['recommendation'] ?? "No recommendation provided.",
    );
  }
}

class Diagnosis {
  final String name;
  final double confidence;
  final String description;

  Diagnosis({
    required this.name,
    required this.confidence,
    required this.description,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      name: json['name'] ?? "Unknown",
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      description: json['description'] ?? "",
    );
  }
}

class Severity {
  final String level;
  final int score;
  final List<String> visualIndicators;

  Severity({
    required this.level,
    required this.score,
    required this.visualIndicators,
  });

  factory Severity.fromJson(Map<String, dynamic> json) {
    return Severity(
      level: json['level'] ?? "Unknown",
      score: json['score'] ?? 0,
      visualIndicators: List<String>.from(json['visual_indicators'] ?? []),
    );
  }
}