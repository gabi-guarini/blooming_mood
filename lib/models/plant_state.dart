class PlantState {
  final int growthLevel; // 0-5 levels
  final int totalMoodPoints;
  final int daysTracked;
  final int currentStreak;
  final String plantImage; // Path to asset or URL
  final String encouragementPhrase;

  PlantState({
    required this.growthLevel,
    required this.totalMoodPoints,
    required this.daysTracked,
    required this.currentStreak,
    required this.plantImage,
    required this.encouragementPhrase,
  });

  // Calculate growth level based on points
  static int calculateGrowthLevel(int points) {
    if (points < 10) return 0; // Seed
    if (points < 30) return 1; // Sprout
    if (points < 60) return 2; // Small plant
    if (points < 100) return 3; // Growing plant
    if (points < 150) return 4; // Flowering
    return 5; // Full bloom
  }

  // Get plant image based on growth level
  static String getPlantImage(int level) {
    switch (level) {
      case 0:
        return 'assets/images/plant_seed.png';
      case 1:
        return 'assets/images/plant_sprout.png';
      case 2:
        return 'assets/images/plant_small.png';
      case 3:
        return 'assets/images/plant_medium.png';
      case 4:
        return 'assets/images/plant_flowering.png';
      case 5:
        return 'assets/images/plant_bloom.png';
      default:
        return 'assets/images/plant_seed.png';
    }
  }

  // Get encouragement phrase based on mood and growth
  static String getEncouragementPhrase(String mood, int growthLevel) {
    final phrases = {
      'happy': [
        "Your joy is helping me bloom! 🌸",
        "Keep spreading that sunshine! ☀️",
        "We're growing together! 🌱",
        "Your happiness makes me thrive! 🌺",
        "Look how far we've come! 🌳",
        "In full bloom, just like your spirit! 🌷"
      ],
      'sad': [
        "Even rain helps flowers grow 🌧️",
        "I'm here with you through this 💙",
        "Tomorrow is a new day to bloom 🌅",
        "Your feelings are valid, let's grow together 🌱",
        "Even the strongest plants need water 💧",
        "You're tending to me even when it's hard 💚"
      ],
      'neutral': [
        "Every day of care counts 🌿",
        "Steady growth is still growth 📈",
        "Balance is beautiful too 🌱",
        "Consistency is key to blooming 🔑",
        "You're doing great! 🌾",
        "Together we grow, day by day 🌳"
      ],
      'anxious': [
        "Breathe with me, we'll grow through this 🍃",
        "Even shaky soil can support strong roots 🌳",
        "You're stronger than you know 💪",
        "One day at a time, one leaf at a time 🍀",
        "Your care still shines through 🌟",
        "Growing isn't always comfortable, but you're doing it! 🌱"
      ],
      'excited': [
        "Your energy is contagious! 🚀",
        "Let's reach for the sky together! ⭐",
        "Your enthusiasm helps me flourish! 🌻",
        "Blooming with excitement! 🎉",
        "Your spark ignites growth! ✨",
        "We're thriving together! 🌺"
      ]
    };

    final moodPhrases = phrases[mood] ?? phrases['neutral']!;
    return moodPhrases[growthLevel.clamp(0, moodPhrases.length - 1)];
  }
}
