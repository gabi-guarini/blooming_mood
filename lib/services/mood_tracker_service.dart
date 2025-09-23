import 'package:blooming_mood/models/mood_model.dart';
import 'package:blooming_mood/models/plant_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MoodTrackerService {
  static const String _moodEntriesKey = 'mood_entries';
  static const String _plantPointsKey = 'plant_points';
  static const String _lastEntryDateKey = 'last_entry_date';
  static const String _streakKey = 'current_streak';

  // Save mood entry and update plant state
  Future<PlantState> trackMood({
    required String mood,
    String? note,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Create mood value based on mood type
    int moodValue = _getMoodValue(mood);

    // Create new mood entry
    final entry = MoodEntry(
      mood: mood,
      timestamp: DateTime.now(),
      note: note,
      moodValue: moodValue,
    );

    // Save mood entry
    await _saveMoodEntry(entry, prefs);

    // Update plant points
    int currentPoints = prefs.getInt(_plantPointsKey) ?? 0;
    currentPoints += moodValue;
    await prefs.setInt(_plantPointsKey, currentPoints);

    // Update streak
    int streak = await _updateStreak(prefs);

    // Get total days tracked
    final entries = await getMoodEntries();
    final uniqueDays = entries
        .map((e) =>
            DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day))
        .toSet()
        .length;

    // Calculate growth level
    int growthLevel = PlantState.calculateGrowthLevel(currentPoints);

    // Create and return plant state
    return PlantState(
      growthLevel: growthLevel,
      totalMoodPoints: currentPoints,
      daysTracked: uniqueDays,
      currentStreak: streak,
      plantImage: PlantState.getPlantImage(growthLevel),
      encouragementPhrase: PlantState.getEncouragementPhrase(mood, growthLevel),
    );
  }

  // Get mood value for plant growth
  int _getMoodValue(String mood) {
    switch (mood) {
      case 'happy':
      case 'excited':
        return 5;
      case 'neutral':
        return 3;
      case 'anxious':
        return 2;
      case 'sad':
        return 2; // Still positive - tracking is what matters!
      default:
        return 3;
    }
  }

  // Save mood entry to local storage
  Future<void> _saveMoodEntry(MoodEntry entry, SharedPreferences prefs) async {
    final entriesJson = prefs.getString(_moodEntriesKey) ?? '[]';
    final entriesList = jsonDecode(entriesJson) as List;
    entriesList.add(entry.toJson());
    await prefs.setString(_moodEntriesKey, jsonEncode(entriesList));
  }

  // Update streak tracking
  Future<int> _updateStreak(SharedPreferences prefs) async {
    final lastEntryStr = prefs.getString(_lastEntryDateKey);
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";

    if (lastEntryStr == null) {
      // First entry ever
      await prefs.setString(_lastEntryDateKey, todayStr);
      await prefs.setInt(_streakKey, 1);
      return 1;
    }

    final lastParts = lastEntryStr.split('-');
    final lastDate = DateTime(
      int.parse(lastParts[0]),
      int.parse(lastParts[1]),
      int.parse(lastParts[2]),
    );

    final daysDiff = today.difference(lastDate).inDays;

    if (daysDiff == 0) {
      // Already tracked today
      return prefs.getInt(_streakKey) ?? 1;
    } else if (daysDiff == 1) {
      // Consecutive day!
      int newStreak = (prefs.getInt(_streakKey) ?? 0) + 1;
      await prefs.setInt(_streakKey, newStreak);
      await prefs.setString(_lastEntryDateKey, todayStr);
      return newStreak;
    } else {
      // Streak broken
      await prefs.setInt(_streakKey, 1);
      await prefs.setString(_lastEntryDateKey, todayStr);
      return 1;
    }
  }

  // Get all mood entries
  Future<List<MoodEntry>> getMoodEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getString(_moodEntriesKey) ?? '[]';
    final entriesList = jsonDecode(entriesJson) as List;
    return entriesList.map((e) => MoodEntry.fromJson(e)).toList();
  }

  // Get current plant state without tracking new mood
  Future<PlantState> getCurrentPlantState() async {
    final prefs = await SharedPreferences.getInstance();
    final points = prefs.getInt(_plantPointsKey) ?? 0;
    final streak = prefs.getInt(_streakKey) ?? 0;
    final entries = await getMoodEntries();

    final uniqueDays = entries
        .map((e) =>
            DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day))
        .toSet()
        .length;

    int growthLevel = PlantState.calculateGrowthLevel(points);

    return PlantState(
      growthLevel: growthLevel,
      totalMoodPoints: points,
      daysTracked: uniqueDays,
      currentStreak: streak,
      plantImage: PlantState.getPlantImage(growthLevel),
      encouragementPhrase: "Welcome back! How are you feeling today? 🌱",
    );
  }

  // Get today's mood entry if exists
  Future<MoodEntry?> getTodaysMood() async {
    final entries = await getMoodEntries();
    final today = DateTime.now();

    try {
      return entries.lastWhere((entry) =>
          entry.timestamp.year == today.year &&
          entry.timestamp.month == today.month &&
          entry.timestamp.day == today.day);
    } catch (e) {
      return null;
    }
  }
}
