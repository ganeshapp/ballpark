import 'problem.dart';

class SessionResult {
  final Problem problem;
  final double userAnswer;
  final Duration timeTaken;
  final bool isCorrect;

  const SessionResult({
    required this.problem,
    required this.userAnswer,
    required this.timeTaken,
    required this.isCorrect,
  });

  double get accuracy => isCorrect ? 100.0 : 0.0;
  double get timeInSeconds => timeTaken.inMilliseconds / 1000.0;
  double get answerDifference => (userAnswer - problem.actualAnswer).abs();
  double get relativeError => problem.actualAnswer != 0 
      ? (answerDifference / problem.actualAnswer) * 100 
      : 0.0;

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