class CheckInRecord {
  CheckInRecord({
    required this.id,
    required this.createdAt,
    required this.qrCodeValue,
    required this.latitude,
    required this.longitude,
    required this.previousTopic,
    required this.expectedTopicToday,
    required this.moodBeforeClass,
  });

  final String id;
  final String createdAt;
  final String qrCodeValue;
  final double latitude;
  final double longitude;
  final String previousTopic;
  final String expectedTopicToday;
  final int moodBeforeClass;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'createdAt': createdAt,
      'qrCodeValue': qrCodeValue,
      'latitude': latitude,
      'longitude': longitude,
      'previousTopic': previousTopic,
      'expectedTopicToday': expectedTopicToday,
      'moodBeforeClass': moodBeforeClass,
    };
  }

  factory CheckInRecord.fromMap(Map<String, Object?> map) {
    return CheckInRecord(
      id: map['id'] as String,
      createdAt: map['createdAt'] as String,
      qrCodeValue: map['qrCodeValue'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      previousTopic: map['previousTopic'] as String,
      expectedTopicToday: map['expectedTopicToday'] as String,
      moodBeforeClass: map['moodBeforeClass'] as int,
    );
  }
}
