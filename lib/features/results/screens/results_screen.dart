import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/session_result.dart';
import '../../../models/session_summary.dart';
import '../../../models/genre.dart';
import '../../home/screens/home_screen.dart';

class ResultsScreen extends StatelessWidget {
  final List<SessionResult> sessionResults;

  const ResultsScreen({
    super.key,
    required this.sessionResults,
  });

  @override
  Widget build(BuildContext context) {
    final summary = _calculateSummary(sessionResults);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Results'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Summary Card
            _buildSummaryCard(context, summary),
            
            // Questions List
            Expanded(
              child: _buildQuestionsList(context),
            ),
            
            // Done Button
            _buildDoneButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, SessionSummary summary) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Session Complete!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Total Questions',
                  '${summary.totalQuestions}',
                  Icons.quiz,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Correct',
                  '${summary.correctAnswers}',
                  Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Accuracy',
                  '${summary.accuracyPercentage.toStringAsFixed(1)}%',
                  Icons.track_changes,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Avg Time',
                  '${summary.averageTimePerQuestion.inSeconds}s',
                  Icons.timer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: Colors.grey[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Question Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Questions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessionResults.length,
              itemBuilder: (context, index) {
                final result = sessionResults[index];
                return _buildQuestionItem(context, result, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(BuildContext context, SessionResult result, int questionNumber) {
    final isCorrect = result.isCorrect;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green[200]! : Colors.red[200]!,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green[600] : Colors.red[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q$questionNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green[600] : Colors.red[600],
                size: 16,
              ),
              const Spacer(),
              Text(
                '${result.timeInSeconds.toStringAsFixed(1)}s',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Question Text
          Text(
            result.problem.questionText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Answers Row
          Row(
            children: [
              // User Answer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Answer:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isCorrect ? Colors.green[300]! : Colors.red[300]!,
                        ),
                      ),
                      child: Text(
                        _formatAnswer(result.userAnswer),
                        style: TextStyle(
                          color: isCorrect ? Colors.green[800] : Colors.red[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Correct Answer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Correct Answer:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blue[300]!),
                      ),
                      child: Text(
                        _formatAnswer(result.problem.actualAnswer),
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => _navigateToHome(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Text(
          'Done',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  String _formatAnswer(double answer) {
    if (answer >= 1000000000) {
      return '${(answer / 1000000000).toStringAsFixed(1)}B';
    } else if (answer >= 1000000) {
      return '${(answer / 1000000).toStringAsFixed(1)}M';
    } else if (answer >= 1000) {
      return '${(answer / 1000).toStringAsFixed(1)}K';
    } else {
      return answer.toStringAsFixed(answer % 1 == 0 ? 0 : 1);
    }
  }

  SessionSummary _calculateSummary(List<SessionResult> results) {
    final totalQuestions = results.length;
    final correctAnswers = results.where((r) => r.isCorrect).length;
    final accuracyPercentage = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;
    
    final totalTime = results.fold<Duration>(
      Duration.zero,
      (sum, result) => sum + result.timeTaken,
    );
    final averageTimePerQuestion = totalQuestions > 0 
      ? Duration(milliseconds: totalTime.inMilliseconds ~/ totalQuestions)
      : Duration.zero;
    
    return SessionSummary(
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      accuracyPercentage: accuracyPercentage,
      averageTimePerQuestion: averageTimePerQuestion,
    );
  }
}

class SessionSummary {
  final int totalQuestions;
  final int correctAnswers;
  final double accuracyPercentage;
  final Duration averageTimePerQuestion;

  const SessionSummary({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracyPercentage,
    required this.averageTimePerQuestion,
  });
}
