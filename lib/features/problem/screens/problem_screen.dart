import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/custom_keypad.dart';
import '../view_models/problem_view_model.dart';
import '../../../models/genre.dart';
import '../../../app/theme/app_theme.dart';

class ProblemScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(problemViewModelProvider({
      'genre': genre,
      'precision': precision,
      'timeLimit': timeLimit,
      'context': context,
    }));
    
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          _handleKeyPress(event, ref, context);
        }
      },
      child: Scaffold(
        backgroundColor: viewModel.showFeedback 
          ? (viewModel.isAnswerCorrect ? Colors.green[50] : Colors.red[50])
          : null,
        appBar: AppBar(
          title: Text(genre.displayName),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Top bar with timer and score
            _buildTopBar(context, viewModel),
            
            // Main content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Question display
                    _buildQuestionSection(context, viewModel),
                    
                    // Answer display
                    _buildAnswerSection(context, viewModel),
                    
                    // Custom keypad
                    _buildKeypadSection(context, ref, viewModel),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ProblemSessionState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Timer
          _buildTimerDisplay(context, state),
          
          // Score
          _buildScoreDisplay(context, state),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(BuildContext context, ProblemSessionState state) {
    final minutes = state.timeRemaining.inMinutes;
    final seconds = state.timeRemaining.inSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: state.timeRemaining.inSeconds < 60 ? Colors.red[100] : Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: state.timeRemaining.inSeconds < 60 ? Colors.red[300]! : Colors.blue[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 18,
            color: state.timeRemaining.inSeconds < 60 ? Colors.red[700] : Colors.blue[700],
          ),
          const SizedBox(width: 8),
          Text(
            timeString,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: state.timeRemaining.inSeconds < 60 ? Colors.red[700] : Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay(BuildContext context, ProblemSessionState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 18,
            color: Colors.green[700],
          ),
          const SizedBox(width: 8),
          Text(
            '${state.score}/${state.problemsCompleted}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(BuildContext context, ProblemSessionState state) {
    return Expanded(
      flex: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(color: AppTheme.textTertiary),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Question ${state.problemsCompleted + 1}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            AnimatedOpacity(
              opacity: state.currentProblem != null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                state.currentProblem?.questionText ?? 'Loading...',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Text(
                'Precision: ±${precision.toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerSection(BuildContext context, ProblemSessionState state) {
    return Expanded(
      flex: 1,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(color: AppTheme.textTertiary),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Answer:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(color: AppTheme.textTertiary),
              ),
              child: Text(
                state.userInput.isEmpty ? '0' : state.userInput,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: state.userInput.isEmpty ? AppTheme.textTertiary : AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadSection(BuildContext context, WidgetRef ref, ProblemSessionState state) {
    final viewModel = ref.read(problemViewModelProvider({
      'genre': genre,
      'precision': precision,
      'timeLimit': timeLimit,
      'context': context,
    }).notifier);
    
    return Expanded(
      flex: 3,
      child: CustomKeypad(
        onKeyPressed: viewModel.onKeyPressed,
        onEnterPressed: viewModel.submitAnswer,
        onBackspacePressed: () => viewModel.onKeyPressed('⌫'),
      ),
    );
  }

  void _handleKeyPress(RawKeyDownEvent event, WidgetRef ref, BuildContext context) {
    final viewModel = ref.read(problemViewModelProvider({
      'genre': genre,
      'precision': precision,
      'timeLimit': timeLimit,
      'context': context,
    }).notifier);

    // Get the logical key
    final logicalKey = event.logicalKey;
    
    // Handle number keys (0-9)
    if (logicalKey == LogicalKeyboardKey.digit0) {
      viewModel.onKeyPressed('0');
    } else if (logicalKey == LogicalKeyboardKey.digit1) {
      viewModel.onKeyPressed('1');
    } else if (logicalKey == LogicalKeyboardKey.digit2) {
      viewModel.onKeyPressed('2');
    } else if (logicalKey == LogicalKeyboardKey.digit3) {
      viewModel.onKeyPressed('3');
    } else if (logicalKey == LogicalKeyboardKey.digit4) {
      viewModel.onKeyPressed('4');
    } else if (logicalKey == LogicalKeyboardKey.digit5) {
      viewModel.onKeyPressed('5');
    } else if (logicalKey == LogicalKeyboardKey.digit6) {
      viewModel.onKeyPressed('6');
    } else if (logicalKey == LogicalKeyboardKey.digit7) {
      viewModel.onKeyPressed('7');
    } else if (logicalKey == LogicalKeyboardKey.digit8) {
      viewModel.onKeyPressed('8');
    } else if (logicalKey == LogicalKeyboardKey.digit9) {
      viewModel.onKeyPressed('9');
    }
    // Handle decimal point
    else if (logicalKey == LogicalKeyboardKey.period || 
             logicalKey == LogicalKeyboardKey.comma) {
      viewModel.onKeyPressed('.');
    }
    // Handle letter keys (K, M, B)
    else if (logicalKey == LogicalKeyboardKey.keyK) {
      viewModel.onKeyPressed('K');
    } else if (logicalKey == LogicalKeyboardKey.keyM) {
      viewModel.onKeyPressed('M');
    } else if (logicalKey == LogicalKeyboardKey.keyB) {
      viewModel.onKeyPressed('B');
    }
    // Handle special keys
    else if (logicalKey == LogicalKeyboardKey.backspace) {
      viewModel.onKeyPressed('⌫');
    } else if (logicalKey == LogicalKeyboardKey.enter || 
               logicalKey == LogicalKeyboardKey.numpadEnter) {
      viewModel.submitAnswer();
    }
    // Handle minus key for sign toggle
    else if (logicalKey == LogicalKeyboardKey.minus || 
             logicalKey == LogicalKeyboardKey.numpadSubtract) {
      viewModel.onKeyPressed('+/-');
    }
    // Handle percentage key
    else if (logicalKey == LogicalKeyboardKey.percent) {
      viewModel.onKeyPressed('%');
    }
  }
}
