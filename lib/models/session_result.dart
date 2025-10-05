import 'problem.dart';

/// Represents the result of a user's attempt to solve a problem
class SessionResult {
  /// The original problem that was presented
  final Problem problem;
  
  /// The answer provided by the user
  final double userAnswer;
  
  /// The time taken by the user to solve the problem
  final Duration timeTaken;
  
  /// Whether the user's answer was correct (within acceptable tolerance)
  final bool isCorrect;
  
  /// Creates a new SessionResult instance
  const SessionResult({
    required this.problem,
    required this.userAnswer,
    required this.timeTaken,
    required this.isCorrect,
  });
  
  /// Creates a copy of this SessionResult with updated values
  SessionResult copyWith({
    Problem? problem,
    double? userAnswer,
    Duration? timeTaken,
    bool? isCorrect,
  }) {
    return SessionResult(
      problem: problem ?? this.problem,
      userAnswer: userAnswer ?? this.userAnswer,
      timeTaken: timeTaken ?? this.timeTaken,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
  
  /// Returns the accuracy percentage (0.0 to 1.0)
  double get accuracy => isCorrect ? 1.0 : 0.0;
  
  /// Returns the time taken in seconds
  double get timeInSeconds => timeTaken.inMilliseconds / 1000.0;
  
  /// Returns the absolute difference between user answer and correct answer
  double get answerDifference => (userAnswer - problem.actualAnswer).abs();
  
  /// Returns the relative error as a percentage
  double get relativeError {
    if (problem.actualAnswer == 0) return 0.0;
    return (answerDifference / problem.actualAnswer.abs()) * 100;
  }
  
  @override
  String toString() {
    return 'SessionResult(problem: $problem, userAnswer: $userAnswer, timeTaken: $timeTaken, isCorrect: $isCorrect)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is SessionResult &&
        other.problem == problem &&
        other.userAnswer == userAnswer &&
        other.timeTaken == timeTaken &&
        other.isCorrect == isCorrect;
  }
  
  @override
  int get hashCode {
    return problem.hashCode ^
        userAnswer.hashCode ^
        timeTaken.hashCode ^
        isCorrect.hashCode;
  }
}
