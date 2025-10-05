import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../view_models/stats_view_model.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(statsViewModelProvider);
    final statsViewModel = ref.read(statsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Stats'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => statsViewModel.refresh(),
          ),
        ],
      ),
      body: statsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : statsState.error != null
              ? _buildErrorState(context, statsState.error!)
              : _buildStatsContent(context, statsState, statsViewModel),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Stats',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, StatsState state, StatsViewModel viewModel) {
    if (state.allSummaries.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genre Filter
          _buildGenreFilter(context, state, viewModel),
          const SizedBox(height: 24),

          // Overall Stats Card
          _buildOverallStatsCard(context, state),
          const SizedBox(height: 24),

          // Performance Over Time Chart
          _buildPerformanceChart(context, state),
          const SizedBox(height: 24),

          // Attempt Volume Chart
          _buildAttemptVolumeChart(context, state),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Data Available',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete some training sessions to see your performance stats',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGenreFilter(BuildContext context, StatsState state, StatsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Genre',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: state.selectedGenre,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: viewModel.availableGenres.map((genre) {
              return DropdownMenuItem<String>(
                value: genre,
                child: Text(genre),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                viewModel.setGenreFilter(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStatsCard(BuildContext context, StatsState state) {
    final overallStats = state.filteredSummaries.isNotEmpty
        ? _calculateOverallStats(state.filteredSummaries)
        : null;

    if (overallStats == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Performance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Sessions',
                  '${overallStats['totalSessions']}',
                  Icons.quiz,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Questions',
                  '${overallStats['totalQuestions']}',
                  Icons.help_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Accuracy',
                  '${overallStats['overallAccuracy'].toStringAsFixed(1)}%',
                  Icons.target,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Avg Time',
                  '${overallStats['averageTimePerQuestion'].inSeconds}s',
                  Icons.timer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(BuildContext context, StatsState state) {
    final performanceData = state.filteredSummaries.isNotEmpty
        ? _preparePerformanceData(state.filteredSummaries)
        : <ChartData>[];

    if (performanceData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Over Time',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < performanceData.length) {
                          return Text(
                            performanceData[value.toInt()].label,
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: performanceData.map((data) => FlSpot(data.x, data.y)).toList(),
                    isCurved: true,
                    color: Colors.blue[600],
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue[50]!,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptVolumeChart(BuildContext context, StatsState state) {
    final volumeData = state.filteredSummaries.isNotEmpty
        ? _prepareVolumeData(state.filteredSummaries)
        : <BarChartData>[];

    if (volumeData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attempt Volume by Day',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: volumeData.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1,
                titlesData: FlTitlesData(
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
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < volumeData.length) {
                          return Text(
                            volumeData[value.toInt()].label,
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                barGroups: volumeData.map((data) {
                  return BarChartGroupData(
                    x: data.x.toInt(),
                    barRods: [
                      BarChartRodData(
                        toY: data.y,
                        color: Colors.green[600],
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateOverallStats(List<dynamic> summaries) {
    final totalSessions = summaries.length;
    final totalQuestions = summaries.fold(0, (sum, s) => sum + s.totalQuestions);
    final totalCorrectAnswers = summaries.fold(0, (sum, s) => sum + s.correctAnswers);
    final overallAccuracy = totalQuestions > 0 ? (totalCorrectAnswers / totalQuestions) * 100 : 0.0;
    
    final totalTimeMs = summaries.fold(0, (sum, s) => 
        sum + (s.averageTimePerQuestion.inMilliseconds * s.totalQuestions));
    final averageTimePerQuestion = totalQuestions > 0 
        ? Duration(milliseconds: totalTimeMs ~/ totalQuestions)
        : Duration.zero;
    
    return {
      'totalSessions': totalSessions,
      'totalQuestions': totalQuestions,
      'totalCorrectAnswers': totalCorrectAnswers,
      'overallAccuracy': overallAccuracy,
      'averageTimePerQuestion': averageTimePerQuestion,
    };
  }

  List<ChartData> _preparePerformanceData(List<dynamic> summaries) {
    final sortedSummaries = List.from(summaries)
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));
    
    return sortedSummaries.asMap().entries.map((entry) {
      final index = entry.key;
      final summary = entry.value;
      return ChartData(
        x: index.toDouble(),
        y: summary.accuracyPercentage,
        label: '${summary.completedAt.day}/${summary.completedAt.month}',
      );
    }).toList();
  }

  List<BarChartData> _prepareVolumeData(List<dynamic> summaries) {
    final Map<String, int> dailyCounts = {};
    for (final summary in summaries) {
      final dateKey = '${summary.completedAt.year}-${summary.completedAt.month.toString().padLeft(2, '0')}-${summary.completedAt.day.toString().padLeft(2, '0')}';
      dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
    }
    
    final sortedDates = dailyCounts.keys.toList()..sort();
    return sortedDates.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      final count = dailyCounts[date]!;
      
      final dateParts = date.split('-');
      final displayDate = '${dateParts[2]}/${dateParts[1]}';
      
      return BarChartData(
        x: index.toDouble(),
        y: count.toDouble(),
        label: displayDate,
      );
    }).toList();
  }
}
