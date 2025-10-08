import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Achievement {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'emoji': emoji,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    emoji: json['emoji'],
    isUnlocked: json['isUnlocked'] ?? false,
    unlockedAt: json['unlockedAt'] != null 
        ? DateTime.parse(json['unlockedAt']) 
        : null,
  );
}

class PersonalBest {
  final String category;
  final double value;
  final DateTime achievedAt;

  PersonalBest({
    required this.category,
    required this.value,
    required this.achievedAt,
  });

  Map<String, dynamic> toJson() => {
    'category': category,
    'value': value,
    'achievedAt': achievedAt.toIso8601String(),
  };

  factory PersonalBest.fromJson(Map<String, dynamic> json) => PersonalBest(
    category: json['category'],
    value: json['value'],
    achievedAt: DateTime.parse(json['achievedAt']),
  );
}

class AchievementService {
  static const String _achievementsKey = 'achievements';
  static const String _personalBestsKey = 'personal_bests';
  static const String _totalCorrectKey = 'total_correct_answers';

  // Define all available achievements
  static final List<Achievement> _allAchievements = [
    Achievement(
      id: 'speed_demon',
      name: 'Speed Demon',
      description: 'Complete 10 problems in under 30 seconds',
      emoji: '⚡',
    ),
    Achievement(
      id: 'perfect_score',
      name: 'Perfect Score',
      description: 'Get 100% accuracy in a session',
      emoji: '🎯',
    ),
    Achievement(
      id: 'century_club',
      name: 'Century Club',
      description: 'Get 100 correct answers total',
      emoji: '💯',
    ),
    Achievement(
      id: 'quick_thinker',
      name: 'Quick Thinker',
      description: 'Average under 3 seconds per question',
      emoji: '🧠',
    ),
    Achievement(
      id: 'consistency_king',
      name: 'Consistency King',
      description: 'Maintain a 3-day streak',
      emoji: '👑',
    ),
  ];

  Future<List<Achievement>> getAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString(_achievementsKey);
    
    if (achievementsJson == null) {
      return _allAchievements;
    }
    
    final List<dynamic> decoded = jsonDecode(achievementsJson);
    final unlockedIds = decoded.map((json) => Achievement.fromJson(json).id).toSet();
    
    return _allAchievements.map((achievement) {
      if (unlockedIds.contains(achievement.id)) {
        final unlocked = decoded.firstWhere((json) => json['id'] == achievement.id);
        return Achievement.fromJson(unlocked);
      }
      return achievement;
    }).toList();
  }

  Future<void> unlockAchievement(String achievementId) async {
    final achievements = await getAchievements();
    final achievement = achievements.firstWhere((a) => a.id == achievementId);
    
    if (achievement.isUnlocked) return; // Already unlocked
    
    final updatedAchievement = Achievement(
      id: achievement.id,
      name: achievement.name,
      description: achievement.description,
      emoji: achievement.emoji,
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );
    
    final updatedList = achievements.map((a) {
      if (a.id == achievementId) return updatedAchievement;
      return a;
    }).where((a) => a.isUnlocked).toList();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _achievementsKey,
      jsonEncode(updatedList.map((a) => a.toJson()).toList()),
    );
  }

  Future<Map<String, PersonalBest>> getPersonalBests() async {
    final prefs = await SharedPreferences.getInstance();
    final bestsJson = prefs.getString(_personalBestsKey);
    
    if (bestsJson == null) {
      return {};
    }
    
    final Map<String, dynamic> decoded = jsonDecode(bestsJson);
    return decoded.map((key, value) => 
      MapEntry(key, PersonalBest.fromJson(value))
    );
  }

  Future<bool> checkAndUpdatePersonalBest(String category, double value) async {
    final bests = await getPersonalBests();
    final currentBest = bests[category];
    
    if (currentBest == null || value > currentBest.value) {
      bests[category] = PersonalBest(
        category: category,
        value: value,
        achievedAt: DateTime.now(),
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _personalBestsKey,
        jsonEncode(bests.map((key, value) => 
          MapEntry(key, value.toJson())
        )),
      );
      
      return true; // New record!
    }
    
    return false;
  }

  Future<void> incrementTotalCorrect(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalCorrectKey) ?? 0;
    await prefs.setInt(_totalCorrectKey, current + count);
  }

  Future<int> getTotalCorrect() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalCorrectKey) ?? 0;
  }

  // Check achievements based on session results
  Future<List<Achievement>> checkAchievements({
    required int correctAnswers,
    required int totalQuestions,
    required Duration sessionDuration,
    required Duration averageTimePerQuestion,
    required int streakDays,
  }) async {
    final newlyUnlocked = <Achievement>[];
    
    // Speed Demon: 10 problems in under 30 seconds
    if (totalQuestions >= 10 && sessionDuration.inSeconds <= 30) {
      final achievement = _allAchievements.firstWhere((a) => a.id == 'speed_demon');
      if (!achievement.isUnlocked) {
        await unlockAchievement('speed_demon');
        newlyUnlocked.add(achievement);
      }
    }
    
    // Perfect Score: 100% accuracy
    if (correctAnswers == totalQuestions && totalQuestions > 0) {
      final achievement = _allAchievements.firstWhere((a) => a.id == 'perfect_score');
      if (!achievement.isUnlocked) {
        await unlockAchievement('perfect_score');
        newlyUnlocked.add(achievement);
      }
    }
    
    // Century Club: 100 total correct
    await incrementTotalCorrect(correctAnswers);
    final totalCorrect = await getTotalCorrect();
    if (totalCorrect >= 100) {
      final achievement = _allAchievements.firstWhere((a) => a.id == 'century_club');
      if (!achievement.isUnlocked) {
        await unlockAchievement('century_club');
        newlyUnlocked.add(achievement);
      }
    }
    
    // Quick Thinker: Average under 3 seconds per question
    if (averageTimePerQuestion.inSeconds < 3 && totalQuestions >= 5) {
      final achievement = _allAchievements.firstWhere((a) => a.id == 'quick_thinker');
      if (!achievement.isUnlocked) {
        await unlockAchievement('quick_thinker');
        newlyUnlocked.add(achievement);
      }
    }
    
    // Consistency King: 3-day streak
    if (streakDays >= 3) {
      final achievement = _allAchievements.firstWhere((a) => a.id == 'consistency_king');
      if (!achievement.isUnlocked) {
        await unlockAchievement('consistency_king');
        newlyUnlocked.add(achievement);
      }
    }
    
    return newlyUnlocked;
  }
}

