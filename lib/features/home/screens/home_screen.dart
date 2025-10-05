import 'package:flutter/material.dart';
import '../../models/genre.dart';
import '../../features/problem/screens/problem_screen.dart';
import '../../features/stats/screens/stats_screen.dart';
import '../../app/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Genre? _selectedGenre;
  double _selectedPrecision = 10.0; // Default to 10%
  int _selectedTimeMinutes = 5; // Default to 5 minutes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BallPark'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title and subtitle
              const SizedBox(height: AppTheme.spacingL),
              Text(
                'Mental Math Trainer',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Train consulting-style mental math with timed problem sets',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingXXL),

              // Genre Selection
              Text(
                'Select Problem Type',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.spacingM),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: Genre.values.length,
                  itemBuilder: (context, index) {
                    final genre = Genre.values[index];
                    final isSelected = _selectedGenre == genre;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: AppTheme.spacingM),
                      child: ChoiceChip(
                        label: Text(
                          genre.displayName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedGenre = selected ? genre : null;
                          });
                        },
                        selectedColor: AppTheme.primaryColor,
                        backgroundColor: AppTheme.backgroundLight,
                        side: BorderSide(
                          color: isSelected 
                            ? AppTheme.primaryColor 
                            : AppTheme.textTertiary,
                          width: isSelected ? 2 : 1,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingS,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacingXXL),

              // Precision Selection
              Text(
                'Precision',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.spacingM),
              SegmentedButton<double>(
                segments: const [
                  ButtonSegment<double>(
                    value: 5.0,
                    label: Text('5%'),
                    icon: Icon(Icons.precision_manufacturing),
                  ),
                  ButtonSegment<double>(
                    value: 10.0,
                    label: Text('10%'),
                    icon: Icon(Icons.precision_manufacturing),
                  ),
                ],
                selected: {_selectedPrecision},
                onSelectionChanged: (Set<double> selection) {
                  setState(() {
                    _selectedPrecision = selection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return Theme.of(context).primaryColor;
                      }
                      return Colors.grey[200]!;
                    },
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return Colors.black87;
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXXL),

              // Time Selection
              Text(
                'Time Limit',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.spacingM),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment<int>(
                    value: 3,
                    label: Text('3:00'),
                    icon: Icon(Icons.timer),
                  ),
                  ButtonSegment<int>(
                    value: 5,
                    label: Text('5:00'),
                    icon: Icon(Icons.timer),
                  ),
                ],
                selected: {_selectedTimeMinutes},
                onSelectionChanged: (Set<int> selection) {
                  setState(() {
                    _selectedTimeMinutes = selection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return Theme.of(context).primaryColor;
                      }
                      return Colors.grey[200]!;
                    },
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return Colors.black87;
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXXL + AppTheme.spacingM),

              // Start Button
              ElevatedButton(
                onPressed: _selectedGenre != null ? _startSession : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedGenre != null ? AppTheme.primaryColor : AppTheme.textTertiary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'START',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),

              // Session Summary
              if (_selectedGenre != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(color: AppTheme.textTertiary),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session Summary',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        'Type: ${_selectedGenre!.displayName}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Precision: ${_selectedPrecision.toInt()}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Time: ${_selectedTimeMinutes}:00',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _startSession() {
    if (_selectedGenre == null) return;

    // For now, just print the selected options
    print('Starting session with:');
    print('Genre: ${_selectedGenre!.displayName}');
    print('Precision: ${_selectedPrecision.toInt()}%');
    print('Time: ${_selectedTimeMinutes}:00');

    // Navigate to ProblemScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProblemScreen(
          genre: _selectedGenre!,
          precision: _selectedPrecision,
          timeLimit: Duration(minutes: _selectedTimeMinutes),
        ),
      ),
    );

    // Show a snackbar for now
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Starting ${_selectedGenre!.displayName} session (${_selectedPrecision.toInt()}% precision, ${_selectedTimeMinutes}:00)',
        ),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
