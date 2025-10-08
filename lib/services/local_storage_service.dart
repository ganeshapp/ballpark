import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_summary.dart';

class LocalStorageService {
  static const String _sessionsKey = 'session_summaries';

  Future<void> saveSessionSummary(SessionSummary summary) async {
    final prefs = await SharedPreferences.getInstance();
    final allSummaries = await getAllSummaries();
    allSummaries.add(summary);
    final jsonList = allSummaries.map((s) => s.toJsonString()).toList();
    await prefs.setStringList(_sessionsKey, jsonList);
  }

  Future<List<SessionSummary>> getAllSummaries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_sessionsKey) ?? [];
    return jsonList
        .map((jsonString) => SessionSummary.fromJsonString(jsonString))
        .whereType<SessionSummary>()
        .toList()
          ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  Future<void> clearAllSummaries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionsKey);
  }

  Future<Map<String, dynamic>> getOverallStats() async {
    final summaries = await getAllSummaries();
    if (summaries.isEmpty) {
      return {
        'totalSessions': 0,
        'totalQuestions': 0,
        'totalCorrectAnswers': 0,
        'overallAccuracy': 0.0,
        'averageTimePerQuestion': Duration.zero,
      };
    }

    final totalSessions = summaries.length;
    final totalQuestions = summaries.fold<int>(0, (sum, s) => sum + s.totalQuestions);
    final totalCorrectAnswers = summaries.fold<int>(0, (sum, s) => sum + s.correctAnswers);
    final overallAccuracy = totalQuestions > 0 ? (totalCorrectAnswers / totalQuestions) * 100 : 0.0;
    
    final totalTimeMs = summaries.fold<int>(0, (sum, s) => 
        sum + (s.averageTimePerQuestion.inMilliseconds * s.totalQuestions));
    final averageTimePerQuestion = totalQuestions > 0 
        ? Duration(milliseconds: totalTimeMs ~/ totalQuestions)
        : Duration.zero;

    return {
      'totalSessions': totalSessions,
      'totalQuestions': totalQuestions,
      'totalCorrectAnswers': totalCorrectAnswers,
      'overallAccuracy': overallAccuracy,
      'averageTimePerQuestion': averageTimePerQuestion,
    };
  }
}