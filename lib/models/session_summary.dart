import 'dart:convert';

/// Represents a summary of a completed mental math training session
class SessionSummary {
  /// Total number of questions attempted in the session
  final int totalQuestions;
  
  /// Number of correct answers
  final int correctAnswers;
  
  /// Accuracy percentage (0.0 to 100.0)
  final double accuracyPercentage;
  
  /// Average time taken per question
  final Duration averageTimePerQuestion;
  
  /// Timestamp when the session was completed
  final DateTime completedAt;
  
  /// The genre of problems practiced in this session
  final String genre;
  
  /// The precision setting used (5% or 10%)
  final double precision;
  
  /// The time limit for the session
  final Duration timeLimit;

  const SessionSummary({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracyPercentage,
    required this.averageTimePerQuestion,
    required this.completedAt,
    required this.genre,
    required this.precision,
    required this.timeLimit,
  });

  /// Creates a SessionSummary from a JSON map
  factory SessionSummary.fromJson(Map<String, dynamic> json) {
    return SessionSummary(
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      accuracyPercentage: (json['accuracyPercentage'] as num).toDouble(),
      averageTimePerQuestion: Duration(milliseconds: json['averageTimePerQuestionMs'] as int),
      completedAt: DateTime.parse(json['completedAt'] as String),
      genre: json['genre'] as String,
      precision: (json['precision'] as num).toDouble(),
      timeLimit: Duration(minutes: json['timeLimitMinutes'] as int),
    );
  }

  /// Converts the SessionSummary to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'accuracyPercentage': accuracyPercentage,
      'averageTimePerQuestionMs': averageTimePerQuestion.inMilliseconds,
      'completedAt': completedAt.toIso8601String(),
      'genre': genre,
      'precision': precision,
      'timeLimitMinutes': timeLimit.inMinutes,
    };
  }

  /// Converts the SessionSummary to a JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Creates a SessionSummary from a JSON string
  factory SessionSummary.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return SessionSummary.fromJson(json);
  }

  /// Creates a copy of this SessionSummary with updated values
  SessionSummary copyWith({
    int? totalQuestions,
    int? correctAnswers,
    double? accuracyPercentage,
    Duration? averageTimePerQuestion,
    DateTime? completedAt,
    String? genre,
    double? precision,
    Duration? timeLimit,
  }) {
    return SessionSummary(
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      accuracyPercentage: accuracyPercentage ?? this.accuracyPercentage,
      averageTimePerQuestion: averageTimePerQuestion ?? this.averageTimePerQuestion,
      completedAt: completedAt ?? this.completedAt,
      genre: genre ?? this.genre,
      precision: precision ?? this.precision,
      timeLimit: timeLimit ?? this.timeLimit,
    );
  }

  @override
  String toString() {
    return 'SessionSummary(totalQuestions: $totalQuestions, correctAnswers: $correctAnswers, accuracyPercentage: $accuracyPercentage, averageTimePerQuestion: $averageTimePerQuestion, completedAt: $completedAt, genre: $genre, precision: $precision, timeLimit: $timeLimit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is SessionSummary &&
        other.totalQuestions == totalQuestions &&
        other.correctAnswers == correctAnswers &&
        other.accuracyPercentage == accuracyPercentage &&
        other.averageTimePerQuestion == averageTimePerQuestion &&
        other.completedAt == completedAt &&
        other.genre == genre &&
        other.precision == precision &&
        other.timeLimit == timeLimit;
  }

  @override
  int get hashCode {
    return totalQuestions.hashCode ^
        correctAnswers.hashCode ^
        accuracyPercentage.hashCode ^
        averageTimePerQuestion.hashCode ^
        completedAt.hashCode ^
        genre.hashCode ^
        precision.hashCode ^
        timeLimit.hashCode;
  }
}
