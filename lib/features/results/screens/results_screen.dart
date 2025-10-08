import 'package:flutter/material.dart';
import '../../../models/session_result.dart';
import '../../../services/achievement_service.dart';
import '../../../services/local_storage_service.dart';
import '../../home/screens/home_screen.dart';

class ResultsScreen extends StatefulWidget {
  final List<SessionResult> sessionResults;

  const ResultsScreen({
    super.key,
    required this.sessionResults,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> with SingleTickerProviderStateMixin {
  final AchievementService _achievementService = AchievementService();
  final LocalStorageService _localStorage = LocalStorageService();
  List<Achievement> _newAchievements = [];
  bool _isNewRecord = false;
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _checkAchievementsAndRecords();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _checkAchievementsAndRecords() async {
    final totalQuestions = widget.sessionResults.length;
    final correctAnswers = widget.sessionResults.where((r) => r.isCorrect).length;
    final accuracy = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;
    final totalTime = widget.sessionResults.fold<Duration>(
      Duration.zero,
      (sum, result) => sum + result.timeTaken,
    );
    final averageTime = totalQuestions > 0 
        ? Duration(milliseconds: totalTime.inMilliseconds ~/ totalQuestions)
        : Duration.zero;

    // Get streak
    final summaries = await _localStorage.getAllSummaries();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;
    if (summaries.isNotEmpty) {
      final sortedDates = summaries.map((s) {
        final date = s.completedAt;
        return DateTime(date.year, date.month, date.day);
      }).toSet().toList()..sort((a, b) => b.compareTo(a));
      
      if (sortedDates.isNotEmpty) {
        var checkDate = today;
        for (var date in sortedDates) {
          if (date == checkDate) {
            streak++;
            checkDate = checkDate.subtract(const Duration(days: 1));
          } else if (date.isBefore(checkDate)) {
            break;
          }
        }
      }
    }
    
    // Check for achievements
    final newAchievements = await _achievementService.checkAchievements(
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      sessionDuration: totalTime,
      averageTimePerQuestion: averageTime,
      streakDays: streak,
    );
    
    // Check for personal best
    final isNewRecord = await _achievementService.checkAndUpdatePersonalBest(
      'accuracy',
      accuracy,
    );
    
    setState(() {
      _newAchievements = newAchievements;
      _isNewRecord = isNewRecord;
    });
  }

  List<SessionResult> get sessionResults => widget.sessionResults;

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
        child: Column(
          children: [
            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFFF3EFFC), const Color(0xFFE8F4FD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF9C7EE8).withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Session Complete!',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF9C7EE8),
                            ),
                          ),
                          // New Record Banner
                          if (_isNewRecord)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [const Color(0xFFFFD56F), const Color(0xFFFFA94D)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD56F).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.emoji_events, color: Colors.white, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    '🎉 NEW RECORD! 🎉',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
                                const Color(0xFF6BB6F5),
                              ),
                              _buildStatItem(
                                context,
                                'Correct Answers',
                                correctAnswers.toString(),
                                Icons.check_circle,
                                const Color(0xFF90E39A),
                              ),
                              _buildStatItem(
                                context,
                                'Accuracy',
                                '${accuracy.toStringAsFixed(1)}%',
                                Icons.track_changes,
                                const Color(0xFFFFD56F),
                              ),
                              _buildStatItem(
                                context,
                                'Avg Time',
                                '${averageTime.inSeconds}s',
                                Icons.timer,
                                const Color(0xFF9C7EE8),
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
                                const Color(0xFF6BB6F5),
                              ),
                              _buildStatItem(
                                context,
                                'Estimation Bias',
                                averageBias > 0 
                                    ? '+${averageBias.toStringAsFixed(1)}%' 
                                    : '${averageBias.toStringAsFixed(1)}%',
                                averageBias > 0 ? Icons.trending_up : Icons.trending_down,
                                averageBias > 0 ? const Color(0xFFFF8B94) : const Color(0xFF6BB6F5),
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

                    // Achievements Section
                    if (_newAchievements.isNotEmpty)
                      Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [const Color(0xFFF3EFFC), const Color(0xFFE8F4FD)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF9C7EE8).withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.celebration, color: const Color(0xFF9C7EE8), size: 28),
                                    const SizedBox(width: 8),
                                    Text(
                                      'New Achievement${_newAchievements.length > 1 ? 's' : ''}!',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF9C7EE8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.center,
                                  children: _newAchievements.map((achievement) {
                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF9C7EE8).withOpacity(0.2),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            achievement.emoji,
                                            style: const TextStyle(fontSize: 32),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            achievement.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            achievement.description,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),

                    // Question Details Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
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

                    const SizedBox(height: 8),

                    // Questions List
                    ...sessionResults.asMap().entries.map((entry) {
                      final index = entry.key;
                      final result = entry.value;
                      return _buildQuestionItem(context, result, index + 1);
                    }).toList(),
                  ],
                ),
              ),
            ),

            // Sticky Done Button at bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF9C7EE8), const Color(0xFF6BB6F5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9C7EE8).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Done',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
    
    // Check if this is a growth rate problem
    final isGrowthRate = result.problem.questionText.toLowerCase().contains('growth rate');
    
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
                isGrowthRate ? '${result.userAnswer.toStringAsFixed(0)}%' : _formatNumber(result.userAnswer),
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
                isGrowthRate ? '${result.problem.actualAnswer.toStringAsFixed(0)}%' : _formatNumber(result.problem.actualAnswer),
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