import 'package:flutter/material.dart';
import '../../../models/genre.dart';
import '../../problem/screens/problem_screen.dart';
import '../../stats/screens/stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Genre _selectedGenre = Genre.addition;
  double _selectedPrecision = 10.0;
  Duration _selectedTimeLimit = const Duration(minutes: 3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Math Trainer'),
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
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(24.0),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Mental Math Trainer',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Train consulting-style mental math with timed problem sets',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Genre Selection
              Text(
                'Select Problem Type:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: Genre.values.length,
                  itemBuilder: (context, index) {
                    final genre = Genre.values[index];
                    final isSelected = _selectedGenre == genre;
                    
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(genre.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedGenre = genre;
                            });
                          }
                        },
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Precision Selection
              Text(
                'Precision:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 16),
              
              SegmentedButton<double>(
                segments: const [
                  ButtonSegment<double>(
                    value: 5.0,
                    label: Text('5%'),
                    icon: Icon(Icons.track_changes),
                  ),
                  ButtonSegment<double>(
                    value: 10.0,
                    label: Text('10%'),
                    icon: Icon(Icons.track_changes),
                  ),
                ],
                selected: {_selectedPrecision},
                onSelectionChanged: (Set<double> selection) {
                  setState(() {
                    _selectedPrecision = selection.first;
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Time Selection
              Text(
                'Time Limit:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 16),
              
              SegmentedButton<Duration>(
                segments: const [
                  ButtonSegment<Duration>(
                    value: Duration(seconds: 30),
                    label: Text('30s'),
                    icon: Icon(Icons.timer),
                  ),
                  ButtonSegment<Duration>(
                    value: Duration(minutes: 3),
                    label: Text('3:00'),
                    icon: Icon(Icons.timer),
                  ),
                  ButtonSegment<Duration>(
                    value: Duration(minutes: 5),
                    label: Text('5:00'),
                    icon: Icon(Icons.timer),
                  ),
                ],
                selected: {_selectedTimeLimit},
                onSelectionChanged: (Set<Duration> selection) {
                  setState(() {
                    _selectedTimeLimit = selection.first;
                  });
                },
              ),
              
              const Spacer(),
              
              // Start Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProblemScreen(
                        genre: _selectedGenre,
                        precision: _selectedPrecision,
                        timeLimit: _selectedTimeLimit,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'START',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
            ),
          ),
        ),
      ),
    );
  }
}