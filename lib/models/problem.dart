/// Represents a single mental math problem
class Problem {
  /// The text representation of the problem/question
  final String questionText;
  
  /// The correct numerical answer to the problem
  final double actualAnswer;
  
  /// Creates a new Problem instance
  const Problem({
    required this.questionText,
    required this.actualAnswer,
  });
  
  /// Creates a copy of this Problem with updated values
  Problem copyWith({
    String? questionText,
    double? actualAnswer,
  }) {
    return Problem(
      questionText: questionText ?? this.questionText,
      actualAnswer: actualAnswer ?? this.actualAnswer,
    );
  }
  
  @override
  String toString() {
    return 'Problem(questionText: $questionText, actualAnswer: $actualAnswer)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Problem &&
        other.questionText == questionText &&
        other.actualAnswer == actualAnswer;
  }
  
  @override
  int get hashCode {
    return questionText.hashCode ^ actualAnswer.hashCode;
  }
}
