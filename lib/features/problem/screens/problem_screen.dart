import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/genre.dart';
import '../../../models/problem.dart';
import '../../../models/session_result.dart';
import '../../../models/session_summary.dart';
import '../../../services/problem_generator_service.dart';
import '../../../services/local_storage_service.dart';
import '../../results/screens/results_screen.dart';

class ProblemScreen extends StatefulWidget {
  final Genre genre;
  final double precision;
  final Duration timeLimit;

  const ProblemScreen({
    super.key,
    required this.genre,
    required this.precision,
    required this.timeLimit,
  });

  @override
  State<ProblemScreen> createState() => _ProblemScreenState();
}

class _ProblemScreenState extends State<ProblemScreen> {
  final ProblemGeneratorService _problemGenerator = ProblemGeneratorService();
  final LocalStorageService _localStorage = LocalStorageService();
  
  Problem? _currentProblem;
  String _userInput = '';
  int _score = 0;
  int _problemsCompleted = 0;
  Duration _timeRemaining = Duration.zero;
  Timer? _timer;
  List<SessionResult> _sessionResults = [];
  bool _isSessionActive = true;
  bool _showFeedback = false;
  bool _isAnswerCorrect = false;
  bool _timerStarted = false;
  DateTime? _questionStartTime;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.timeLimit;
    _generateNewProblem();
    // Timer will start after first answer is submitted
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateNewProblem() {
    setState(() {
      _currentProblem = _problemGenerator.generateProblem(widget.genre);
      _userInput = '';
      _showFeedback = false;
      _isAnswerCorrect = false;
      _questionStartTime = DateTime.now(); // Start timing this question
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining.inSeconds > 0) {
        setState(() {
          _timeRemaining = Duration(seconds: _timeRemaining.inSeconds - 1);
        });
      } else {
        _endSession();
      }
    });
  }

  void _onKeyPressed(String key) {
    if (!_isSessionActive) return;

    switch (key) {
      case '⌫':
        setState(() {
          if (_userInput.isNotEmpty) {
            _userInput = _userInput.substring(0, _userInput.length - 1);
          }
        });
        break;
      case 'ENTER':
        _submitAnswer();
        break;
      case '+/-':
        setState(() {
          if (_userInput.isNotEmpty && _userInput != '0') {
            _userInput = _userInput.startsWith('-') 
                ? _userInput.substring(1) 
                : '-$_userInput';
          }
        });
        break;
      case '%':
        setState(() {
          if (!_userInput.contains('%')) {
            _userInput += '%';
          }
        });
        break;
      case 'K':
        _multiplyBySuffix(1000);
        break;
      case 'M':
        _multiplyBySuffix(1000000);
        break;
      case 'B':
        _multiplyBySuffix(1000000000);
        break;
      default:
        setState(() {
          if (key == '.') {
            if (!_userInput.contains('.')) {
              _userInput += key;
            }
          } else {
            _userInput = _userInput == '0' ? key : _userInput + key;
          }
        });
    }
  }

  void _multiplyBySuffix(int multiplier) {
    if (_userInput.isEmpty) return;
    
    try {
      double value = _parseInputValue(_userInput);
      double result = value * multiplier;
      setState(() {
        _userInput = _formatNumber(result);
      });
    } catch (e) {
      // Invalid input, don't update
    }
  }

  double _parseInputValue(String input) {
    if (input.isEmpty) return 0.0;
    
    String cleanInput = input.toUpperCase();
    double multiplier = 1.0;
    
    if (cleanInput.endsWith('B')) {
      multiplier = 1000000000.0;
      cleanInput = cleanInput.substring(0, cleanInput.length - 1);
    } else if (cleanInput.endsWith('M')) {
      multiplier = 1000000.0;
      cleanInput = cleanInput.substring(0, cleanInput.length - 1);
    } else if (cleanInput.endsWith('K')) {
      multiplier = 1000.0;
      cleanInput = cleanInput.substring(0, cleanInput.length - 1);
    } else if (cleanInput.endsWith('%')) {
      cleanInput = cleanInput.substring(0, cleanInput.length - 1);
    }
    
    try {
      double baseValue = double.parse(cleanInput);
      return baseValue * multiplier;
    } catch (e) {
      return 0.0;
    }
  }

  String _formatNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  void _submitAnswer() {
    if (!_isSessionActive || _userInput.isEmpty || _currentProblem == null) return;

    // Start timer after first answer is submitted
    if (!_timerStarted) {
      _timerStarted = true;
      _startTimer();
    }

    try {
      final userAnswer = _parseInputValue(_userInput);
      final correctAnswer = _currentProblem!.actualAnswer;
      final tolerance = (correctAnswer * widget.precision) / 100;
      final isCorrect = (userAnswer - correctAnswer).abs() <= tolerance;

      // Calculate actual time taken for this question
      final timeTaken = _questionStartTime != null
          ? DateTime.now().difference(_questionStartTime!)
          : const Duration(seconds: 0);

      // Create session result
      final sessionResult = SessionResult(
        problem: _currentProblem!,
        userAnswer: userAnswer,
        timeTaken: timeTaken,
        isCorrect: isCorrect,
      );

      setState(() {
        _sessionResults.add(sessionResult);
        if (isCorrect) {
          _score++;
        }
        _problemsCompleted++;
        _showFeedback = true;
        _isAnswerCorrect = isCorrect;
      });

      // Show feedback briefly, then generate next problem
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_isSessionActive) {
          _generateNewProblem();
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  void _endSession() async {
    _timer?.cancel();
    setState(() {
      _isSessionActive = false;
    });

    if (_problemsCompleted > 0) {
      final accuracy = (_score / _problemsCompleted) * 100;
      final totalTime = widget.timeLimit - _timeRemaining;
      final averageTime = Duration(milliseconds: totalTime.inMilliseconds ~/ _problemsCompleted);

      // Calculate average precision error (per question, then average)
      final totalPrecisionError = _sessionResults.fold<double>(0.0, (sum, r) {
        if (r.problem.actualAnswer == 0) return sum; // Skip division by zero
        final error = ((r.userAnswer - r.problem.actualAnswer) / r.problem.actualAnswer).abs() * 100;
        return sum + error;
      });
      final avgPrecisionError = _problemsCompleted > 0 ? totalPrecisionError / _problemsCompleted : 0.0;
      
      print('DEBUG: Total sessions completed: $_problemsCompleted');
      print('DEBUG: Total precision error sum: $totalPrecisionError');
      print('DEBUG: Average precision error: $avgPrecisionError');
      
      final summary = SessionSummary(
        totalQuestions: _problemsCompleted,
        correctAnswers: _score,
        accuracyPercentage: accuracy,
        averageTimePerQuestion: averageTime,
        completedAt: DateTime.now(),
        genre: widget.genre.displayName,
        precision: widget.precision,
        timeLimit: widget.timeLimit,
        averagePrecisionError: avgPrecisionError,
      );

      await _localStorage.saveSessionSummary(summary);
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(sessionResults: _sessionResults),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.digit0 || key == LogicalKeyboardKey.numpad0) _onKeyPressed('0');
          else if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1) _onKeyPressed('1');
          else if (key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.numpad2) _onKeyPressed('2');
          else if (key == LogicalKeyboardKey.digit3 || key == LogicalKeyboardKey.numpad3) _onKeyPressed('3');
          else if (key == LogicalKeyboardKey.digit4 || key == LogicalKeyboardKey.numpad4) _onKeyPressed('4');
          else if (key == LogicalKeyboardKey.digit5 || key == LogicalKeyboardKey.numpad5) _onKeyPressed('5');
          else if (key == LogicalKeyboardKey.digit6 || key == LogicalKeyboardKey.numpad6) _onKeyPressed('6');
          else if (key == LogicalKeyboardKey.digit7 || key == LogicalKeyboardKey.numpad7) _onKeyPressed('7');
          else if (key == LogicalKeyboardKey.digit8 || key == LogicalKeyboardKey.numpad8) _onKeyPressed('8');
          else if (key == LogicalKeyboardKey.digit9 || key == LogicalKeyboardKey.numpad9) _onKeyPressed('9');
          else if (key == LogicalKeyboardKey.period || key == LogicalKeyboardKey.numpadDecimal) _onKeyPressed('.');
          else if (key == LogicalKeyboardKey.backspace) _onKeyPressed('⌫');
          else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) _onKeyPressed('ENTER');
          else if (key == LogicalKeyboardKey.minus) _onKeyPressed('+/-');
          else if (key == LogicalKeyboardKey.keyK) _onKeyPressed('K');
          else if (key == LogicalKeyboardKey.keyM) _onKeyPressed('M');
          else if (key == LogicalKeyboardKey.keyB) _onKeyPressed('B');
        }
      },
      child: Scaffold(
        backgroundColor: _showFeedback 
            ? (_isAnswerCorrect ? Colors.green.shade50 : Colors.red.shade50)
            : null,
        appBar: AppBar(
          title: Text(widget.genre.displayName),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
          // Timer and Score
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${_timeRemaining.inMinutes}:${(_timeRemaining.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '$_score/$_problemsCompleted',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Question
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Question Card
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
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
                        children: [
                          Text(
                            'Question ${_problemsCompleted + 1}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _currentProblem?.questionText ?? 'Loading...',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Answer Input
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _userInput.isEmpty ? '0' : _userInput,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: _userInput.isEmpty ? Colors.grey[400] : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Keypad
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: _buildKeypad(),
          ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        // First row: 1, 2, 3, +/-
        _buildKeypadRow(['1', '2', '3', '+/-']),
        const SizedBox(height: 12),
        
        // Second row: 4, 5, 6, %
        _buildKeypadRow(['4', '5', '6', '%']),
        const SizedBox(height: 12),
        
        // Third row: 7, 8, 9, K
        _buildKeypadRow(['7', '8', '9', 'K']),
        const SizedBox(height: 12),
        
        // Fourth row: ., 0, M, B
        _buildKeypadRow(['.', '0', 'M', 'B']),
        const SizedBox(height: 12),
        
        // Fifth row: ENTER, ⌫
        _buildActionRow(),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildKeypadButton(key)).toList(),
    );
  }

  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 3,
          child: _buildActionButton('ENTER', () => _onKeyPressed('ENTER')),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: _buildActionButton('⌫', () => _onKeyPressed('⌫')),
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String text) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => _onKeyPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: text == 'ENTER' ? Colors.green : Colors.orange,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}