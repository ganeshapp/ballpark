class Problem {
  final String questionText;
  final double actualAnswer;

  const Problem({
    required this.questionText,
    required this.actualAnswer,
  });

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