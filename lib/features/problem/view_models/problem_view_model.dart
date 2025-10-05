import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/problem.dart';
import '../../../models/genre.dart';
import '../../../models/session_summary.dart';
import '../../../models/session_result.dart';
import '../../../services/problem_generator_service.dart';
import '../../../services/local_storage_service.dart';
import '../../results/screens/results_screen.dart' as results;

// Global navigator key for navigation without context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ProblemSessionState {
  final Problem? currentProblem;
  final String userInput;
  final int score;
  final int problemsCompleted;
  final Duration timeRemaining;
  final bool isAnswerCorrect;
  final bool showFeedback;
  final bool isSessionActive;
  final List<SessionResult> sessionResults;

  const ProblemSessionState({
    this.currentProblem,
    this.userInput = '',
    this.score = 0,
    this.problemsCompleted = 0,
    this.timeRemaining = const Duration(minutes: 5),
    this.isAnswerCorrect = false,
    this.showFeedback = false,
    this.isSessionActive = true,
    this.sessionResults = const [],
  });

  ProblemSessionState copyWith({
    Problem? currentProblem,
    String? userInput,
    int? score,
    int? problemsCompleted,
    Duration? timeRemaining,
    bool? isAnswerCorrect,
    bool? showFeedback,
    bool? isSessionActive,
    List<SessionResult>? sessionResults,
  }) {
    return ProblemSessionState(
      currentProblem: currentProblem ?? this.currentProblem,
      userInput: userInput ?? this.userInput,
      score: score ?? this.score,
      problemsCompleted: problemsCompleted ?? this.problemsCompleted,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isAnswerCorrect: isAnswerCorrect ?? this.isAnswerCorrect,
      showFeedback: showFeedback ?? this.showFeedback,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      sessionResults: sessionResults ?? this.sessionResults,
    );
  }
}

class ProblemViewModel extends StateNotifier<ProblemSessionState> {
  final ProblemGeneratorService _problemGenerator;
  final LocalStorageService _localStorage;
  final Genre _genre;
  final double _precision;
  final Duration _timeLimit;
  Timer? _timer;
  bool _isGeneratingProblem = false;
  DateTime _sessionStartTime = DateTime.now();

  ProblemViewModel({
    required ProblemGeneratorService problemGenerator,
    required LocalStorageService localStorage,
    required Genre genre,
    required double precision,
    required Duration timeLimit,
  })  : _problemGenerator = problemGenerator,
        _localStorage = localStorage,
        _genre = genre,
        _precision = precision,
        _timeLimit = timeLimit,
        super(ProblemSessionState(timeRemaining: timeLimit)) {
    _startSession();
  }


  void _startSession() {
    print('Starting session with genre: ${_genre.displayName}');
    _generateNewProblem();
    _startTimer();
  }

  void _startTimer() {
    // Cancel any existing timer first
    _timer?.cancel();
    
    print('Starting timer with ${state.timeRemaining.inSeconds} seconds remaining');
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining.inSeconds > 0) {
        final newTime = Duration(seconds: state.timeRemaining.inSeconds - 1);
        print('Timer tick: ${newTime.inSeconds} seconds remaining');
        state = state.copyWith(
          timeRemaining: newTime,
        );
      } else {
        print('Timer ended - calling _endSession()');
        _endSession();
      }
    });
  }

  void _generateNewProblem() {
    // Prevent generating new problems if session is not active or already generating
    if (!state.isSessionActive || _isGeneratingProblem) {
      print('Skipping problem generation - session active: ${state.isSessionActive}, generating: $_isGeneratingProblem');
      return;
    }
    
    print('Generating new problem...');
    _isGeneratingProblem = true;
    
    final problem = _problemGenerator.generateProblem(_genre);
    state = state.copyWith(
      currentProblem: problem,
      userInput: '',
      showFeedback: false,
      isAnswerCorrect: false,
    );
    
    _isGeneratingProblem = false;
    print('Problem generated: ${problem.questionText}');
  }

  void updateUserInput(String input) {
    if (!state.isSessionActive) {
      print('Cannot update input - session not active');
      return;
    }
    
    print('Updating user input from "${state.userInput}" to "$input"');
    state = state.copyWith(userInput: input);
  }

  void onKeyPressed(String key) {
    if (!state.isSessionActive) {
      print('Key pressed but session not active: $key');
      return;
    }

    print('Key pressed: $key, current input: "${state.userInput}"');
    String newInput = state.userInput;

    switch (key) {
      case '+/-':
        _toggleSign();
        break;
      case '%':
        _appendPercentage();
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
      case '⌫':
        _backspace();
        break;
      default:
        _appendCharacter(key);
    }
  }

  void _toggleSign() {
    if (state.userInput.isEmpty) return;
    
    String newInput = state.userInput;
    if (newInput.startsWith('-')) {
      newInput = newInput.substring(1);
    } else if (newInput != '0' && newInput.isNotEmpty) {
      newInput = '-$newInput';
    }
    
    updateUserInput(newInput);
  }

  void _appendPercentage() {
    if (state.userInput.isEmpty) return;
    
    String newInput = state.userInput;
    if (!newInput.contains('%')) {
      newInput += '%';
      updateUserInput(newInput);
    }
  }

  void _multiplyBySuffix(int multiplier) {
    if (state.userInput.isEmpty) return;
    
    String newInput = state.userInput;
    if (newInput.contains('K') || newInput.contains('M') || newInput.contains('B')) {
      return; // Already has a suffix
    }
    
    try {
      double value = _parseInputValue(newInput);
      double result = value * multiplier;
      newInput = _formatNumber(result);
      updateUserInput(newInput);
    } catch (e) {
      // Invalid input, don't update
    }
  }

  void _backspace() {
    if (state.userInput.isEmpty) return;
    
    String newInput = state.userInput.substring(0, state.userInput.length - 1);
    updateUserInput(newInput);
  }

  void _appendCharacter(String character) {
    String newInput = state.userInput;
    
    if (character == '.') {
      if (!newInput.contains('.')) {
        newInput += character;
      }
    } else {
      if (newInput == '0') {
        newInput = character;
      } else {
        newInput += character;
      }
    }
    
    updateUserInput(newInput);
  }

  double _parseInputValue(String input) {
    if (input.isEmpty) return 0.0;
    
    // Handle suffixes properly
    String cleanInput = input.toUpperCase();
    double multiplier = 1.0;
    
    if (cleanInput.endsWith('B')) {
      multiplier = 1000000000.0; // Billion
      cleanInput = cleanInput.substring(0, cleanInput.length - 1);
    } else if (cleanInput.endsWith('M')) {
      multiplier = 1000000.0; // Million
      cleanInput = cleanInput.substring(0, cleanInput.length - 1);
    } else if (cleanInput.endsWith('K')) {
      multiplier = 1000.0; // Thousand
      cleanInput = cleanInput.substring(0, cleanInput.length - 1);
    } else if (cleanInput.endsWith('%')) {
      // For percentages, we'll handle this differently
      cleanInput = cleanInput.substring(0, cleanInput.length - 1);
      // Don't apply multiplier for percentages - they should be handled as-is
    }
    
    try {
      double baseValue = double.parse(cleanInput);
      return baseValue * multiplier;
    } catch (e) {
      print('Error parsing input "$input": $e');
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
      return number.toStringAsFixed(number % 1 == 0 ? 0 : 1);
    }
  }

  void submitAnswer() {
    if (!state.isSessionActive || state.userInput.isEmpty) return;

    try {
      final userAnswer = _parseInputValue(state.userInput);
      final correctAnswer = state.currentProblem!.actualAnswer;
      
      print('Submitting answer:');
      print('  User input: "${state.userInput}"');
      print('  Parsed user answer: $userAnswer');
      print('  Correct answer: $correctAnswer');
      print('  Precision: $_precision%');
      
      // Calculate tolerance based on precision
      final tolerance = (correctAnswer * _precision) / 100;
      final isCorrect = (userAnswer - correctAnswer).abs() <= tolerance;
      
      print('  Tolerance: $tolerance');
      print('  Difference: ${(userAnswer - correctAnswer).abs()}');
      print('  Is correct: $isCorrect');
      
      // Create session result for this problem
      final sessionResult = SessionResult(
        problem: state.currentProblem!,
        userAnswer: userAnswer,
        timeTaken: Duration(seconds: 15), // TODO: Track actual time per problem
        isCorrect: isCorrect,
      );
      
      // Add to session results
      final newSessionResults = List<SessionResult>.from(state.sessionResults)
        ..add(sessionResult);
      
      // Show feedback
      state = state.copyWith(
        isAnswerCorrect: isCorrect,
        showFeedback: true,
        sessionResults: newSessionResults,
      );
      
      // Update score
      final newScore = isCorrect ? state.score + 1 : state.score;
      final newProblemsCompleted = state.problemsCompleted + 1;
      
      state = state.copyWith(
        score: newScore,
        problemsCompleted: newProblemsCompleted,
      );
      
      // Hide feedback after delay and generate next problem
      Timer(const Duration(milliseconds: 1500), () {
        if (state.isSessionActive && !_isGeneratingProblem) {
          _generateNewProblem();
        }
      });
      
    } catch (e) {
      // Invalid input, show error feedback
      state = state.copyWith(
        isAnswerCorrect: false,
        showFeedback: true,
      );
      
      Timer(const Duration(milliseconds: 1500), () {
        if (state.isSessionActive) {
          state = state.copyWith(showFeedback: false);
        }
      });
    }
  }

  void _endSession() async {
    _timer?.cancel();
    state = state.copyWith(isSessionActive: false);
    
    // Calculate session summary
    final summary = _calculateSessionSummary();
    
    // Save to local storage
    try {
      await _localStorage.saveSessionSummary(summary);
    } catch (e) {
      // Handle storage error gracefully
      print('Failed to save session summary: $e');
    }
    
    // Navigate to results screen
    _navigateToResults();
  }
  
  SessionSummary _calculateSessionSummary() {
    final totalQuestions = state.sessionResults.length;
    final correctAnswers = state.sessionResults.where((r) => r.isCorrect).length;
    final accuracyPercentage = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;
    
    final totalTime = state.sessionResults.fold<Duration>(
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
      completedAt: DateTime.now(),
      genre: _genre.displayName,
      precision: _precision,
      timeLimit: _timeLimit,
    );
  }
  
  void _navigateToResults() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => results.ResultsScreen(
            sessionResults: state.sessionResults,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _isGeneratingProblem = false;
    super.dispose();
  }
}

// Provider for the ProblemGeneratorService
final problemGeneratorServiceProvider = Provider<ProblemGeneratorService>((ref) {
  return ProblemGeneratorService();
});

// Provider for the LocalStorageService
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// Provider for the ProblemViewModel
final problemViewModelProvider = StateNotifierProvider.family<ProblemViewModel, ProblemSessionState, String>((ref, params) {
  final problemGenerator = ref.watch(problemGeneratorServiceProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  
  // Parse the parameters from the string key
  final parts = params.split('|');
  final genre = Genre.values.firstWhere((g) => g.name == parts[0]);
  final precision = double.parse(parts[1]);
  final timeLimit = Duration(seconds: int.parse(parts[2]));
  
  print('Creating ProblemViewModel with genre: ${genre.displayName}, precision: $precision, timeLimit: ${timeLimit.inSeconds}s');
  
  return ProblemViewModel(
    problemGenerator: problemGenerator,
    localStorage: localStorage,
    genre: genre,
    precision: precision,
    timeLimit: timeLimit,
  );
});
