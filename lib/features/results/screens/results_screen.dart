import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/session_result.dart';
import '../../home/screens/home_screen.dart';

class ResultsScreen extends StatelessWidget {
  final List<SessionResult> sessionResults;

  const ResultsScreen({
    super.key,
    required this.sessionResults,
  });

  double _calculateErrorPercentage(double userAnswer, double correctAnswer) {
    if (correctAnswer == 0) return 0.0;
    return ((userAnswer - correctAnswer) / correctAnswer) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = sessionResults.length;
    final correctAnswers = sessionResults.where((r) => r.isCorrect).length;
    final accuracy = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;
    final totalTime = sessionResults.fold<Duration>(
      Duration.zero,
      (sum, result) => sum + result.timeTaken,
    );
    final averageTime = totalQuestions > 0 
        ? Duration(milliseconds: totalTime.inMilliseconds ~/ totalQuestions)
        : Duration.zero;
    
    // Calculate average precision error (absolute)
    final totalError = sessionResults.fold<double>(
        0.0, (sum, r) => sum + _calculateErrorPercentage(r.userAnswer, r.problem.actualAnswer).abs());
    final averagePrecisionError = totalQuestions > 0 ? totalError / totalQuestions : 0.0;
    
    // Calculate bias (positive = overestimating, negative = underestimating)
    final totalSignedError = sessionResults.fold<double>(
        0.0, (sum, r) => sum + _calculateErrorPercentage(r.userAnswer, r.problem.actualAnswer));
    final averageBias = totalQuestions > 0 ? totalSignedError / totalQuestions : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Results'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'Session Complete!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          'Total Questions',
                          totalQuestions.toString(),
                          Icons.quiz,
                          Colors.blue,
                        ),
                        _buildStatItem(
                          context,
                          'Correct Answers',
                          correctAnswers.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _buildStatItem(
                          context,
                          'Accuracy',
                          '${accuracy.toStringAsFixed(1)}%',
                          Icons.track_changes,
                          Colors.orange,
                        ),
                        _buildStatItem(
                          context,
                          'Avg Time',
                          '${averageTime.inSeconds}s',
                          Icons.timer,
                          Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          'Avg Precision',
                          '±${averagePrecisionError.toStringAsFixed(1)}%',
                          Icons.straighten,
                          Colors.teal,
                        ),
                        _buildStatItem(
                          context,
                          'Estimation Bias',
                          averageBias > 0 
                              ? '+${averageBias.toStringAsFixed(1)}%' 
                              : '${averageBias.toStringAsFixed(1)}%',
                          averageBias > 0 ? Icons.trending_up : Icons.trending_down,
                          averageBias > 0 ? Colors.red : Colors.blue,
                        ),
                      ],
                    ),
                    if (averageBias.abs() > 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          averageBias > 0 
                              ? '📈 You tend to overestimate' 
                              : '📉 You tend to underestimate',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Questions List
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.list, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Question Details',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: sessionResults.length,
                          itemBuilder: (context, index) {
                            final result = sessionResults[index];
                            return _buildQuestionItem(context, result, index + 1);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Done Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionItem(BuildContext context, SessionResult result, int questionNumber) {
    final errorPercentage = _calculateErrorPercentage(result.userAnswer, result.problem.actualAnswer);
    final errorAbs = errorPercentage.abs();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: result.isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Q$questionNumber',
                  style: TextStyle(
                    color: result.isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                result.isCorrect ? Icons.check_circle : Icons.cancel,
                color: result.isCorrect ? Colors.green : Colors.red,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result.problem.questionText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Your answer: ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                _formatNumber(result.userAnswer),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: result.isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Correct: ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                _formatNumber(result.problem.actualAnswer),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: errorPercentage > 0 ? Colors.red.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: errorPercentage > 0 ? Colors.red.shade200 : Colors.blue.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      errorPercentage > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: errorPercentage > 0 ? Colors.red.shade700 : Colors.blue.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${errorPercentage > 0 ? '+' : ''}${errorPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: errorPercentage > 0 ? Colors.red.shade700 : Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                errorPercentage > 0 ? 'overestimated' : 'underestimated',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }
}