import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/session_summary.dart';
import '../../../services/local_storage_service.dart';
import '../widgets/streak_calendar.dart';

enum TimeView { daily, weekly, monthly }

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final LocalStorageService _localStorage = LocalStorageService();
  List<SessionSummary> _allSummaries = [];
  bool _isLoading = true;
  String? _selectedGenre; // null = All Genres
  TimeView _timeView = TimeView.daily;

  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }

  Future<void> _loadSummaries() async {
    setState(() {
      _isLoading = true;
    });
    _allSummaries = await _localStorage.getAllSummaries();
    setState(() {
      _isLoading = false;
    });
  }

  List<SessionSummary> get _filteredSummaries {
    if (_selectedGenre == null) return _allSummaries;
    return _allSummaries.where((s) => s.genre == _selectedGenre).toList();
  }

  Map<String, List<SessionSummary>> _groupByPeriod() {
    final Map<String, List<SessionSummary>> grouped = {};
    
    for (var summary in _filteredSummaries) {
      String key;
      switch (_timeView) {
        case TimeView.daily:
          key = '${summary.completedAt.year}-${summary.completedAt.month.toString().padLeft(2, '0')}-${summary.completedAt.day.toString().padLeft(2, '0')}';
          break;
        case TimeView.weekly:
          final weekNumber = _getWeekNumber(summary.completedAt);
          key = '${summary.completedAt.year}-W${weekNumber.toString().padLeft(2, '0')}';
          break;
        case TimeView.monthly:
          key = '${summary.completedAt.year}-${summary.completedAt.month.toString().padLeft(2, '0')}';
          break;
      }
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(summary);
    }
    
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil() + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allSummaries.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No session data available yet.\nComplete some sessions to see stats!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildFilters(),
                          const SizedBox(height: 16),
                          
                          // Streak Calendar
                          if (_allSummaries.isNotEmpty)
                            StreakCalendar(summaries: _allSummaries),
                          
                          const SizedBox(height: 16),
                          
                          // Warning banner if precision is 0 (old data)
                          if (_filteredSummaries.isNotEmpty && 
                              _filteredSummaries.every((s) => s.averagePrecisionError == 0.0))
                            Card(
                              color: Colors.orange.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Old Data Detected',
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade900,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Your saved sessions don\'t have precision data. Clear stats and complete new sessions to see precision metrics.',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.orange.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Clear All Statistics?'),
                                            content: const Text(
                                              'This will permanently delete all session data. This cannot be undone.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: const Text('Clear All'),
                                              ),
                                            ],
                                          ),
                                        );
                                        
                                        if (confirm == true) {
                                          await _localStorage.clearAllSummaries();
                                          _loadSummaries();
                                        }
                                      },
                                      icon: const Icon(Icons.delete_forever, size: 18),
                                      label: const Text('Clear Now'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange.shade700,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 24),
                          _buildSummaryCards(),
                          const SizedBox(height: 24),
                          _buildTimeSpentChart(),
                          const SizedBox(height: 24),
                          _buildQuestionsAttemptedChart(),
                          const SizedBox(height: 24),
                          _buildAccuracyTrendChart(),
                          const SizedBox(height: 24),
                          _buildPrecisionChart(),
                          const SizedBox(height: 24),
                          _buildSpeedChart(),
                          const SizedBox(height: 32),
                          
                          // Clear Stats Button
                          ElevatedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Clear All Statistics?'),
                                  content: const Text(
                                    'This will permanently delete all session data. This cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Clear All'),
                                    ),
                                  ],
                                ),
                              );
                              
                              if (confirm == true) {
                                await _localStorage.clearAllSummaries();
                                _loadSummaries();
                              }
                            },
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Clear All Statistics'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildFilters() {
    final availableGenres = _allSummaries.map((s) => s.genre).toSet().toList()..sort();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Genre Filter
            Text(
              'Filter by Genre:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: _selectedGenre,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Genres')),
                ...availableGenres.map((genre) => DropdownMenuItem(
                  value: genre,
                  child: Text(genre),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGenre = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Time View Selector
            Text(
              'Time View:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<TimeView>(
              segments: const [
                ButtonSegment(value: TimeView.daily, label: Text('Daily'), icon: Icon(Icons.today)),
                ButtonSegment(value: TimeView.weekly, label: Text('Weekly'), icon: Icon(Icons.view_week)),
                ButtonSegment(value: TimeView.monthly, label: Text('Monthly'), icon: Icon(Icons.calendar_month)),
              ],
              selected: {_timeView},
              onSelectionChanged: (Set<TimeView> selection) {
                setState(() {
                  _timeView = selection.first;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalSessions = _filteredSummaries.length;
    final totalQuestions = _filteredSummaries.fold<int>(0, (sum, s) => sum + s.totalQuestions);
    final totalCorrect = _filteredSummaries.fold<int>(0, (sum, s) => sum + s.correctAnswers);
    final accuracy = totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0.0;
    
    // Calculate average precision (correctly: per session precision, then average)
    final totalPrecisionError = _filteredSummaries.fold<double>(0.0, (sum, s) {
      return sum + s.averagePrecisionError;
    });
    final avgPrecision = totalSessions > 0 ? totalPrecisionError / totalSessions : 0.0;
    
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Overall Statistics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  context,
                  'Sessions',
                  totalSessions.toString(),
                  Icons.bar_chart,
                  Colors.blue,
                ),
                _buildSummaryItem(
                  context,
                  'Questions',
                  totalQuestions.toString(),
                  Icons.quiz,
                  Colors.green,
                ),
                _buildSummaryItem(
                  context,
                  'Accuracy',
                  '${accuracy.toStringAsFixed(1)}%',
                  Icons.track_changes,
                  Colors.orange,
                ),
                _buildSummaryItem(
                  context,
                  'Avg Precision',
                  '±${avgPrecision.toStringAsFixed(1)}%',
                  Icons.straighten,
                  Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSpentChart() {
    final grouped = _groupByPeriod();
    if (grouped.isEmpty) return const SizedBox.shrink();
    
    final data = grouped.entries.map((entry) {
      // Sum up actual time spent (time limit - time remaining = time used)
      final totalTimeSeconds = entry.value.fold<int>(
        0, 
        (sum, s) {
          // For each session, we spent the full timeLimit (or until timer hit 0)
          // Since we're storing timeLimit, that's the max time spent
          return sum + s.timeLimit.inSeconds;
        },
      );
      // Convert to minutes for display
      return MapEntry(entry.key, totalTimeSeconds / 60.0);
    }).toList();
    
    return _buildBarChart(
      'Time Spent per ${_timeView.name.substring(0, 1).toUpperCase()}${_timeView.name.substring(1)}',
      data,
      Colors.purple,
      'minutes',
    );
  }

  Widget _buildQuestionsAttemptedChart() {
    final grouped = _groupByPeriod();
    if (grouped.isEmpty) return const SizedBox.shrink();
    
    final data = grouped.entries.map((entry) {
      final totalQuestions = entry.value.fold<int>(0, (sum, s) => sum + s.totalQuestions);
      return MapEntry(entry.key, totalQuestions.toDouble());
    }).toList();
    
    return _buildBarChart(
      'Questions Attempted per ${_timeView.name.substring(0, 1).toUpperCase()}${_timeView.name.substring(1)}',
      data,
      Colors.blue,
      'questions',
    );
  }

  Widget _buildAccuracyTrendChart() {
    final grouped = _groupByPeriod();
    if (grouped.isEmpty) return const SizedBox.shrink();
    
    final data = grouped.entries.map((entry) {
      final totalQuestions = entry.value.fold<int>(0, (sum, s) => sum + s.totalQuestions);
      final totalCorrect = entry.value.fold<int>(0, (sum, s) => sum + s.correctAnswers);
      final accuracy = totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0.0;
      return MapEntry(entry.key, accuracy);
    }).toList();
    
    return _buildLineChart(
      'Accuracy Trend by ${_timeView.name.substring(0, 1).toUpperCase()}${_timeView.name.substring(1)}',
      data,
      Colors.green,
      '%',
    );
  }

  Widget _buildPrecisionChart() {
    final grouped = _groupByPeriod();
    if (grouped.isEmpty) return const SizedBox.shrink();
    
    final data = grouped.entries.map((entry) {
      // Correctly: average of per-session precision errors
      final avgPrecisionError = entry.value.fold<double>(
        0.0, 
        (sum, s) => sum + s.averagePrecisionError,
      ) / entry.value.length;
      return MapEntry(entry.key, avgPrecisionError);
    }).toList();
    
    return _buildLineChart(
      'Precision Error by ${_timeView.name.substring(0, 1).toUpperCase()}${_timeView.name.substring(1)}',
      data,
      Colors.teal,
      '%',
    );
  }

  Widget _buildSpeedChart() {
    final grouped = _groupByPeriod();
    if (grouped.isEmpty) return const SizedBox.shrink();
    
    final data = grouped.entries.map((entry) {
      final avgSpeed = entry.value.fold<double>(
        0.0, 
        (sum, s) => sum + s.averageTimePerQuestion.inSeconds.toDouble(),
      ) / entry.value.length;
      return MapEntry(entry.key, avgSpeed);
    }).toList();
    
    return _buildLineChart(
      'Avg Speed per Question by ${_timeView.name.substring(0, 1).toUpperCase()}${_timeView.name.substring(1)}',
      data,
      Colors.deepOrange,
      'sec',
    );
  }

  Widget _buildBarChart(String title, List<MapEntry<String, double>> data, Color color, String unit) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue * 1.2,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= data.length) return const Text('');
                          final key = data[value.toInt()].key;
                          final label = _formatPeriodLabel(key);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              label,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.value,
                          color: color,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(String title, List<MapEntry<String, double>> data, Color color, String unit) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    
    // Calculate better min/max with padding
    final range = maxValue - minValue;
    final paddedMin = minValue - (range * 0.1);
    final paddedMax = maxValue + (range * 0.1);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  minY: paddedMin > 0 ? paddedMin : 0,
                  maxY: paddedMax,
                  lineTouchData: LineTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= data.length) return const Text('');
                          final key = data[value.toInt()].key;
                          final label = _formatPeriodLabel(key);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              label,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.value);
                      }).toList(),
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPeriodLabel(String key) {
    switch (_timeView) {
      case TimeView.daily:
        final parts = key.split('-');
        return '${parts[1]}/${parts[2]}';
      case TimeView.weekly:
        final parts = key.split('-W');
        return 'W${parts[1]}';
      case TimeView.monthly:
        final parts = key.split('-');
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return months[int.parse(parts[1]) - 1];
    }
  }
}
