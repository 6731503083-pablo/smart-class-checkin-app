class FinishClassRecord {
  FinishClassRecord({
    required this.id,
    required this.createdAt,
    required this.qrCodeValue,
    required this.latitude,
    required this.longitude,
    required this.learnedToday,
    required this.classFeedback,
  });

  final String id;
  final String createdAt;
  final String qrCodeValue;
  final double latitude;
  final double longitude;
  final String learnedToday;
  final String classFeedback;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'qrCodeValue': qrCodeValue,
      'latitude': latitude,
      'longitude': longitude,
      'learnedToday': learnedToday,
      'classFeedback': classFeedback,
    };
  }

  factory FinishClassRecord.fromMap(Map<String, Object?> map) {
    return FinishClassRecord(
      id: map['id'] as String,
      createdAt: map['createdAt'] as String,
      qrCodeValue: map['qrCodeValue'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      learnedToday: map['learnedToday'] as String,
      classFeedback: map['classFeedback'] as String,
    );
  }
}
