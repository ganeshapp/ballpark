import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_summary.dart';

/// Service for managing local storage of session data using SharedPreferences
class LocalStorageService {
  static const String _sessionSummariesKey = 'session_summaries';
  
  /// Saves a session summary to local storage
  /// 
  /// The summary is added to a list of all saved summaries and stored as JSON
  Future<void> saveSessionSummary(SessionSummary summary) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing summaries
      final existingSummaries = await getAllSummaries();
      
      // Add the new summary to the list
      existingSummaries.add(summary);
      
      // Convert all summaries to JSON strings
      final jsonStrings = existingSummaries
          .map((summary) => summary.toJsonString())
          .toList();
      
      // Save the list of JSON strings
      await prefs.setStringList(_sessionSummariesKey, jsonStrings);
      
    } catch (e) {
      throw LocalStorageException('Failed to save session summary: $e');
    }
  }
  
  /// Retrieves all saved session summaries from local storage
  /// 
  /// Returns an empty list if no summaries are found or if there's an error
  Future<List<SessionSummary>> getAllSummaries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStrings = prefs.getStringList(_sessionSummariesKey) ?? [];
      
      // Convert JSON strings back to SessionSummary objects
      final summaries = jsonStrings
          .map((jsonString) => SessionSummary.fromJsonString(jsonString))
          .toList();
      
      // Sort by completion date (most recent first)
      summaries.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      
      return summaries;
      
    } catch (e) {
      // Return empty list on error to prevent app crashes
      return [];
    }
  }
  
  /// Clears all saved session summaries
  Future<void> clearAllSummaries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionSummariesKey);
    } catch (e) {
      throw LocalStorageException('Failed to clear session summaries: $e');
    }
  }
  
  /// Gets the total number of saved session summaries
  Future<int> getSummaryCount() async {
    final summaries = await getAllSummaries();
    return summaries.length;
  }
  
  /// Gets session summaries for a specific genre
  Future<List<SessionSummary>> getSummariesByGenre(String genre) async {
    final allSummaries = await getAllSummaries();
    return allSummaries.where((summary) => summary.genre == genre).toList();
  }
  
  /// Gets the most recent session summary
  Future<SessionSummary?> getMostRecentSummary() async {
    final summaries = await getAllSummaries();
    return summaries.isNotEmpty ? summaries.first : null;
  }
  
  /// Gets statistics across all sessions
  Future<OverallStats> getOverallStats() async {
    final summaries = await getAllSummaries();
    
    if (summaries.isEmpty) {
      return OverallStats(
        totalSessions: 0,
        totalQuestions: 0,
        totalCorrectAnswers: 0,
        overallAccuracy: 0.0,
        averageTimePerQuestion: Duration.zero,
        favoriteGenre: null,
      );
    }
    
    final totalSessions = summaries.length;
    final totalQuestions = summaries.fold(0, (sum, s) => sum + s.totalQuestions);
    final totalCorrectAnswers = summaries.fold(0, (sum, s) => sum + s.correctAnswers);
    final overallAccuracy = totalQuestions > 0 ? (totalCorrectAnswers / totalQuestions) * 100 : 0.0;
    
    // Calculate average time per question across all sessions
    final totalTimeMs = summaries.fold(0, (sum, s) => 
        sum + (s.averageTimePerQuestion.inMilliseconds * s.totalQuestions));
    final averageTimePerQuestion = totalQuestions > 0 
        ? Duration(milliseconds: totalTimeMs ~/ totalQuestions)
        : Duration.zero;
    
    // Find favorite genre (most practiced)
    final genreCounts = <String, int>{};
    for (final summary in summaries) {
      genreCounts[summary.genre] = (genreCounts[summary.genre] ?? 0) + 1;
    }
    final favoriteGenre = genreCounts.isNotEmpty 
        ? genreCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : null;
    
    return OverallStats(
      totalSessions: totalSessions,
      totalQuestions: totalQuestions,
      totalCorrectAnswers: totalCorrectAnswers,
      overallAccuracy: overallAccuracy,
      averageTimePerQuestion: averageTimePerQuestion,
      favoriteGenre: favoriteGenre,
    );
  }
}

/// Exception thrown when local storage operations fail
class LocalStorageException implements Exception {
  final String message;
  
  const LocalStorageException(this.message);
  
  @override
  String toString() => 'LocalStorageException: $message';
}

/// Statistics across all saved sessions
class OverallStats {
  final int totalSessions;
  final int totalQuestions;
  final int totalCorrectAnswers;
  final double overallAccuracy;
  final Duration averageTimePerQuestion;
  final String? favoriteGenre;
  
  const OverallStats({
    required this.totalSessions,
    required this.totalQuestions,
    required this.totalCorrectAnswers,
    required this.overallAccuracy,
    required this.averageTimePerQuestion,
    required this.favoriteGenre,
  });
  
  @override
  String toString() {
    return 'OverallStats(totalSessions: $totalSessions, totalQuestions: $totalQuestions, totalCorrectAnswers: $totalCorrectAnswers, overallAccuracy: $overallAccuracy, averageTimePerQuestion: $averageTimePerQuestion, favoriteGenre: $favoriteGenre)';
  }
}
