import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

class CustomKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final Function()? onEnterPressed;
  final Function()? onBackspacePressed;

  const CustomKeypad({
    super.key,
    required this.onKeyPressed,
    this.onEnterPressed,
    this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        children: [
          // First row: 1, 2, 3, +/-
          _buildKeypadRow(['1', '2', '3', '+/-']),
          const SizedBox(height: AppTheme.spacingS),
          
          // Second row: 4, 5, 6, %
          _buildKeypadRow(['4', '5', '6', '%']),
          const SizedBox(height: AppTheme.spacingS),
          
          // Third row: 7, 8, 9, K
          _buildKeypadRow(['7', '8', '9', 'K']),
          const SizedBox(height: AppTheme.spacingS),
          
          // Fourth row: ., 0, M, B
          _buildKeypadRow(['.', '0', 'M', 'B']),
          const SizedBox(height: AppTheme.spacingS),
          
          // Fifth row: ENTER, ⌫
          _buildActionRow(),
        ],
      ),
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
          child: _buildActionButton('ENTER', onEnterPressed),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: _buildActionButton('⌫', onBackspacePressed),
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String text) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXS),
        child: ElevatedButton(
          onPressed: () {
            print('KEYPAD DEBUG: Button pressed: $text');
            onKeyPressed(text);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.backgroundLight,
            foregroundColor: AppTheme.textPrimary,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
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

  Widget _buildActionButton(String text, VoidCallback? onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXS),
      child: ElevatedButton(
        onPressed: () {
          print('KEYPAD DEBUG: Action button pressed: $text');
          onPressed?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: text == 'ENTER' 
            ? AppTheme.successColor 
            : AppTheme.warningColor,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
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
