class MoodEntry {
  final String mood; // 'happy', 'sad', 'neutral', 'anxious', 'excited'
  final DateTime timestamp;
  final String? note;
  final int moodValue; // 1-5 scale for plant growth calculation

  MoodEntry({
    required this.mood,
    required this.timestamp,
    this.note,
    required this.moodValue,
  });

  Map<String, dynamic> toJson() => {
        'mood': mood,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
        'moodValue': moodValue,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        mood: json['mood'],
        timestamp: DateTime.parse(json['timestamp']),
        note: json['note'],
        moodValue: json['moodValue'],
      );
}
