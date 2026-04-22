class VibeResult {
  final int vibeScore;
  final String tagline;

  VibeResult({required this.vibeScore, required this.tagline});

  factory VibeResult.fromJson(Map<String, dynamic> json) {
    return VibeResult(
      vibeScore: json['vibeScore'],
      tagline: json['tagline'],
    );
  }
}
