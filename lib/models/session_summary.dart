import 'dart:convert';

class SessionSummary {
  final int totalQuestions;
  final int correctAnswers;
  final double accuracyPercentage;
  final Duration averageTimePerQuestion;
  final DateTime completedAt;
  final String genre;
  final double precision; // Tolerance threshold (5% or 10%)
  final Duration timeLimit;
  final double averagePrecisionError; // Actual average precision error per question

  const SessionSummary({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracyPercentage,
    required this.averageTimePerQuestion,
    required this.completedAt,
    required this.genre,
    required this.precision,
    required this.timeLimit,
    required this.averagePrecisionError,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'accuracyPercentage': accuracyPercentage,
      'averageTimePerQuestion': averageTimePerQuestion.inMilliseconds,
      'completedAt': completedAt.toIso8601String(),
      'genre': genre,
      'precision': precision,
      'timeLimit': timeLimit.inSeconds,
      'averagePrecisionError': averagePrecisionError,
    };
  }

  factory SessionSummary.fromJson(Map<String, dynamic> json) {
    return SessionSummary(
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      accuracyPercentage: (json['accuracyPercentage'] as num?)?.toDouble() ?? 0.0,
      averageTimePerQuestion: Duration(milliseconds: json['averageTimePerQuestion'] as int? ?? 0),
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ?? DateTime.now(),
      genre: json['genre'] as String? ?? '',
      precision: (json['precision'] as num?)?.toDouble() ?? 10.0,
      timeLimit: Duration(seconds: json['timeLimit'] as int? ?? 300),
      averagePrecisionError: (json['averagePrecisionError'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory SessionSummary.fromJsonString(String jsonString) {
    return SessionSummary.fromJson(jsonDecode(jsonString));
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
        other.timeLimit == timeLimit &&
        other.averagePrecisionError == averagePrecisionError;
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
        timeLimit.hashCode ^
        averagePrecisionError.hashCode;
  }
}