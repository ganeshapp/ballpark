import 'package:flutter/material.dart';
import '../../../models/genre.dart';
import '../../problem/screens/problem_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../../../services/local_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  Genre _selectedGenre = Genre.addition;
  double _selectedPrecision = 10.0;
  Duration _selectedTimeLimit = const Duration(minutes: 3);
  bool _isPracticeMode = false;
  final LocalStorageService _localStorage = LocalStorageService();
  late AnimationController _pulseController;
  
  int _todaysSessions = 0;
  int _todaysCorrect = 0;
  int _streakDays = 0;

  @override
  void initState() {
    super.initState();
    _loadTodaysProgress();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadTodaysProgress() async {
    final summaries = await _localStorage.getAllSummaries();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Today's stats
    final todaysSummaries = summaries.where((s) {
      final date = DateTime(s.completedAt.year, s.completedAt.month, s.completedAt.day);
      return date == today;
    }).toList();
    
    final sessions = todaysSummaries.length;
    final correct = todaysSummaries.fold(0, (sum, s) => sum + s.correctAnswers);
    
    // Calculate streak
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
    
    setState(() {
      _todaysSessions = sessions;
      _todaysCorrect = correct;
      _streakDays = streak;
    });
  }

  void _showOnboarding() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.blue.shade50,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Centered title and tagline
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                    child: Column(
                      children: [
                        Text(
                          'Ballpark',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Tagline with help icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Directionally correct, incredibly fast',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.help_outline, color: Colors.purple.shade400),
                              onPressed: _showOnboarding,
                              tooltip: 'How to play',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Scrollable content area
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 24),
                                
                                // Today's Progress Card
                                if (_todaysSessions > 0 || _streakDays > 0)
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.purple.shade400, Colors.blue.shade400],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.purple.shade200.withOpacity(0.5),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Today's Progress",
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            _buildProgressStat(
                                              icon: Icons.check_circle_outline,
                                              value: _todaysCorrect.toString(),
                                              label: 'Correct',
                                            ),
                                            _buildProgressStat(
                                              icon: Icons.quiz_outlined,
                                              value: _todaysSessions.toString(),
                                              label: 'Sessions',
                                            ),
                                            _buildProgressStat(
                                              icon: Icons.local_fire_department_outlined,
                                              value: _streakDays.toString(),
                                              label: _streakDays == 1 ? 'Day' : 'Day Streak',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                const SizedBox(height: 24),
                                
                                // Mode Selection
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildModeButton(
                                          label: '🎓 Practice',
                                          isSelected: _isPracticeMode,
                                          onTap: () {
                                            setState(() {
                                              _isPracticeMode = true;
                                            });
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildModeButton(
                                          label: '🏆 Challenge',
                                          isSelected: !_isPracticeMode,
                                          onTap: () {
                                            setState(() {
                                              _isPracticeMode = false;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Precision Selection
                                Text(
                                  'Precision:',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                SegmentedButton<double>(
                                  segments: const [
                                    ButtonSegment<double>(
                                      value: 5.0,
                                      label: Text('±5%'),
                                      icon: Icon(Icons.precision_manufacturing),
                                    ),
                                    ButtonSegment<double>(
                                      value: 10.0,
                                      label: Text('±10%'),
                                      icon: Icon(Icons.track_changes),
                                    ),
                                  ],
                                  selected: {_selectedPrecision},
                                  onSelectionChanged: (Set<double> selection) {
                                    setState(() {
                                      _selectedPrecision = selection.first;
                                    });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                                      if (states.contains(MaterialState.selected)) {
                                        return Colors.purple.shade100;
                                      }
                                      return Colors.white;
                                    }),
                                    foregroundColor: MaterialStateProperty.resolveWith((states) {
                                      if (states.contains(MaterialState.selected)) {
                                        return Colors.purple.shade700;
                                      }
                                      return Colors.grey[700];
                                    }),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Time Selection (only for Challenge mode)
                                if (!_isPracticeMode) ...[
                                  Text(
                                    'Time Limit:',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  SegmentedButton<Duration>(
                                    segments: const [
                                      ButtonSegment<Duration>(
                                        value: Duration(seconds: 30),
                                        label: Text('30s'),
                                        icon: Icon(Icons.bolt),
                                      ),
                                      ButtonSegment<Duration>(
                                        value: Duration(minutes: 3),
                                        label: Text('3:00'),
                                        icon: Icon(Icons.timer),
                                      ),
                                      ButtonSegment<Duration>(
                                        value: Duration(minutes: 5),
                                        label: Text('5:00'),
                                        icon: Icon(Icons.schedule),
                                      ),
                                    ],
                                    selected: {_selectedTimeLimit},
                                    onSelectionChanged: (Set<Duration> selection) {
                                      setState(() {
                                        _selectedTimeLimit = selection.first;
                                      });
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.resolveWith((states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return Colors.blue.shade100;
                                        }
                                        return Colors.white;
                                      }),
                                      foregroundColor: MaterialStateProperty.resolveWith((states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return Colors.blue.shade700;
                                        }
                                        return Colors.grey[700];
                                      }),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                ],
                                
                                // Genre Selection
                                Text(
                                  'Select Problem Type:',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final width = constraints.maxWidth;
                                    int crossAxisCount;
                                    if (width >= 700) {
                                      crossAxisCount = 5;
                                    } else if (width >= 550) {
                                      crossAxisCount = 4;
                                    } else if (width >= 400) {
                                      crossAxisCount = 3;
                                    } else {
                                      crossAxisCount = 2;
                                    }
                                    
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        childAspectRatio: 1.0,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                      ),
                                      itemCount: Genre.values.length,
                                      itemBuilder: (context, index) {
                                        final genre = Genre.values[index];
                                        final isSelected = _selectedGenre == genre;
                                        
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              _selectedGenre = genre;
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(16),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            decoration: BoxDecoration(
                                              color: isSelected 
                                                  ? Colors.purple.shade100
                                                  : Colors.white,
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: isSelected 
                                                    ? Colors.purple.shade400
                                                    : Colors.grey.shade300,
                                                width: isSelected ? 2.5 : 1,
                                              ),
                                              boxShadow: isSelected ? [
                                                BoxShadow(
                                                  color: Colors.purple.shade200.withOpacity(0.5),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ] : [],
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                  genre.displayName,
                                                  style: TextStyle(
                                                    color: isSelected 
                                                        ? Colors.purple.shade700
                                                        : Colors.grey.shade700,
                                                    fontWeight: isSelected 
                                                        ? FontWeight.bold 
                                                        : FontWeight.w500,
                                                    fontSize: 13,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                                
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                        
                        // Sticky Start Button at bottom
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 24),
                          child: AnimatedScale(
                            scale: 1.0,
                            duration: const Duration(milliseconds: 100),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProblemScreen(
                                      genre: _selectedGenre,
                                      precision: _selectedPrecision,
                                      timeLimit: _isPracticeMode ? null : _selectedTimeLimit,
                                    ),
                                  ),
                                ).then((_) => _loadTodaysProgress());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple.shade400,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                elevation: 5,
                                shadowColor: Colors.purple.shade200,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_isPracticeMode ? Icons.school : Icons.rocket_launch),
                                  const SizedBox(width: 12),
                                  Text(
                                    _isPracticeMode ? 'START PRACTICE' : 'START CHALLENGE',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
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
                ),
              ),
            ],
          ),
          // Stats icon positioned in top-right
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.analytics_outlined, color: Colors.purple.shade700),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatsScreen(),
                  ),
                );
              },
              tooltip: 'View Stats',
            ),
          ),
        ],
      ),
    ),
      ),
    );
  }

  Widget _buildProgressStat({required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? LinearGradient(
                  colors: [Colors.purple.shade400, Colors.blue.shade400],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// Onboarding Screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _currentPage >= index 
                              ? Colors.purple.shade400 
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildOnboardingPage(
                      title: 'Welcome to Ballpark! 👋',
                      description: 'Train your mental math superpowers with quick estimations',
                      icon: Icons.emoji_events,
                      color: Colors.purple,
                    ),
                    _buildOnboardingPage(
                      title: 'Estimate Quickly',
                      description: 'You don\'t need exact answers!\n\n898K + 149K ≈ 1M\n\nClose enough wins!',
                      icon: Icons.speed,
                      color: Colors.blue,
                    ),
                    _buildOnboardingPage(
                      title: 'Stay Within Range',
                      description: 'Get within ±10% to score points\n\nThe correct answer is 1.047M\nAnything from 942K to 1.15M wins!',
                      icon: Icons.track_changes,
                      color: Colors.green,
                    ),
                    _buildOnboardingPage(
                      title: 'Ready to Play? 🎯',
                      description: 'Choose Practice mode to learn\nor Challenge mode to race against time!',
                      icon: Icons.rocket_launch,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              
              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Back'),
                      )
                    else
                      const SizedBox(width: 80),
                    
                    if (_currentPage < 3)
                      ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text('Next'),
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text('Get Started!'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: color,
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            description,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
