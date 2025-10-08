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
  final Duration? timeLimit; // Optional for practice mode

  const ProblemScreen({
    super.key,
    required this.genre,
    required this.precision,
    this.timeLimit, // Optional
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
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.timeLimit ?? const Duration(hours: 24); // Effectively unlimited for practice mode
    _generateNewProblem();
    // Timer will start after first answer is submitted (if not practice mode)
  }

  @override
  void dispose() {
    _timer?.cancel();
    _feedbackTimer?.cancel();
    super.dispose();
  }

  void _generateNewProblem({bool keepFeedback = false}) {
    setState(() {
      _currentProblem = _problemGenerator.generateProblem(widget.genre);
      _userInput = '';
      if (!keepFeedback) {
        _showFeedback = false;
        _isAnswerCorrect = false;
      }
      _questionStartTime = DateTime.now(); // Start timing this question
    });
  }

  void _startTimer() {
    if (widget.timeLimit == null) return; // Don't start timer in practice mode
    
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
      double userAnswer = _parseInputValue(_userInput);
      final correctAnswer = _currentProblem!.actualAnswer;
      
      // Special handling for growth rate problems
      // Users can enter either "0.5" (decimal) or "50%" (percentage)
      // Both should be normalized to 50 for comparison
      if (widget.genre == Genre.growthRate) {
        // If user entered a small decimal (< 10), assume it's decimal form and convert to percentage
        if (userAnswer < 10 && userAnswer > 0) {
          userAnswer = userAnswer * 100;
        }
      }
      
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

      // Move to next question immediately, keeping feedback visible
      _generateNewProblem(keepFeedback: true);
      
      // Hide feedback after a short delay
      _feedbackTimer?.cancel();
      _feedbackTimer = Timer(const Duration(milliseconds: 800), () {
        if (_isSessionActive) {
          setState(() {
            _showFeedback = false;
            _isAnswerCorrect = false;
          });
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
      // For practice mode, calculate actual time spent from session results
      final totalTime = widget.timeLimit != null
          ? widget.timeLimit! - _timeRemaining
          : _sessionResults.fold<Duration>(Duration.zero, (sum, r) => sum + r.timeTaken);
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
        timeLimit: widget.timeLimit ?? const Duration(minutes: 999), // Use a large value for practice mode
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
            ? (_isAnswerCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE))
            : null,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Circular progress timer (or infinity for practice mode)
              widget.timeLimit == null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C7EE8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF9C7EE8).withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.all_inclusive, color: Color(0xFF9C7EE8), size: 18),
                      ],
                    ),
                  )
                : SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _timeRemaining.inSeconds / widget.timeLimit!.inSeconds,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _timeRemaining.inSeconds > (widget.timeLimit!.inSeconds * 0.25)
                                ? const Color(0xFF90E39A) // Soft green
                                : const Color(0xFFFF8B94), // Soft red
                          ),
                          strokeWidth: 4,
                        ),
                        Text(
                          '${_timeRemaining.inMinutes}:${(_timeRemaining.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: _timeRemaining.inSeconds > (widget.timeLimit!.inSeconds * 0.25)
                                ? const Color(0xFF90E39A) // Soft green
                                : const Color(0xFFFF8B94), // Soft red
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              Text(
                widget.genre.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF90E39A).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF90E39A).withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Color(0xFF90E39A), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '$_score/$_problemsCompleted',
                      style: const TextStyle(
                        color: Color(0xFF2D2640),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate optimal width based on available height
            final availableHeight = constraints.maxHeight;
            final questionBoxHeight = 100.0;
            final answerBoxHeight = 60.0;
            final topSpacing = 16.0;
            
            // Remaining height for keypad (5 rows + enter row)
            final keypadAvailableHeight = availableHeight - questionBoxHeight - answerBoxHeight - topSpacing - 100;
            
            // Each keypad button should be square, 5 rows of buttons
            final buttonSize = keypadAvailableHeight / 5.5; // 5 rows + action row
            
            // Width = 4 buttons across + margins
            final optimalWidth = (buttonSize * 4) + 40; // 40 for padding
            
            // Constrain between 380 and 500
            final containerWidth = optimalWidth.clamp(380.0, 500.0);
            
            return Center(
              child: Container(
                width: containerWidth,
                child: Column(
                  children: [
                    // Question and Answer section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          // Question Card
                          Container(
                            height: questionBoxHeight,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
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
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: containerWidth - 60, // Allow text to wrap
                                  ),
                                  child: Text(
                                    _currentProblem?.questionText ?? 'Loading...',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      height: 1.25,
                                      fontSize: 20,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Answer Input
                          Container(
                            height: answerBoxHeight,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
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
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _userInput.isEmpty ? '0' : _userInput,
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: _userInput.isEmpty ? Colors.grey[400] : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),

                    // Keypad
                    Container(
                      padding: const EdgeInsets.all(8),
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        // First row: 7, 8, 9, %
        _buildKeypadRow(['7', '8', '9', '%']),
        
        // Second row: 4, 5, 6, K
        _buildKeypadRow(['4', '5', '6', 'K']),
        
        // Third row: 1, 2, 3, M
        _buildKeypadRow(['1', '2', '3', 'M']),
        
        // Fourth row: ., 0, +/-, B
        _buildKeypadRow(['.', '0', '+/-', 'B']),
        
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
          child: Container(
            margin: const EdgeInsets.all(2),
            child: _buildActionButton('ENTER', () => _onKeyPressed('ENTER')),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(2),
            child: _buildActionButton('⌫', () => _onKeyPressed('⌫')),
          ),
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String text) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0, // Square buttons
        child: Container(
          margin: const EdgeInsets.all(2),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 1.0),
            duration: const Duration(milliseconds: 100),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: ElevatedButton(
                  onPressed: () {
                    // Trigger animation
                    _onKeyPressed(text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: text == 'ENTER' ? const Color(0xFF9C7EE8) : const Color(0xFFF5A3C7),
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24), // Increased from 16 to 24
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18, // Slightly larger font
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}