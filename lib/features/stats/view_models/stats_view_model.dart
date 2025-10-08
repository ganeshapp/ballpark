import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/session_summary.dart';
import '../../../services/local_storage_service.dart';

class StatsState {
  final List<SessionSummary> allSummaries;
  final List<SessionSummary> filteredSummaries;
  final String selectedGenre;
  final bool isLoading;
  final String? error;

  const StatsState({
    this.allSummaries = const [],
    this.filteredSummaries = const [],
    this.selectedGenre = 'All',
    this.isLoading = true,
    this.error,
  });

  StatsState copyWith({
    List<SessionSummary>? allSummaries,
    List<SessionSummary>? filteredSummaries,
    String? selectedGenre,
    bool? isLoading,
    String? error,
  }) {
    return StatsState(
      allSummaries: allSummaries ?? this.allSummaries,
      filteredSummaries: filteredSummaries ?? this.filteredSummaries,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class StatsViewModel extends StateNotifier<StatsState> {
  final LocalStorageService _localStorage;

  StatsViewModel({required LocalStorageService localStorage})
      : _localStorage = localStorage,
        super(const StatsState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final summaries = await _localStorage.getAllSummaries();
      
      state = state.copyWith(
        allSummaries: summaries,
        filteredSummaries: summaries,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load stats: $e',
      );
    }
  }

  void setGenreFilter(String genre) {
    final filtered = genre == 'All'
        ? state.allSummaries
        : state.allSummaries.where((s) => s.genre == genre).toList();
    
    state = state.copyWith(
      selectedGenre: genre,
      filteredSummaries: filtered,
    );
  }

  List<String> get availableGenres {
    final genres = state.allSummaries.map((s) => s.genre).toSet().toList();
    genres.sort();
    return ['All', ...genres];
  }

  // Chart data preparation
  List<ChartData> get performanceOverTimeData {
    if (state.filteredSummaries.isEmpty) return [];
    
    // Sort by completion date
    final sortedSummaries = List<SessionSummary>.from(state.filteredSummaries)
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

  List<ChartData> get averageTimeOverTimeData {
    if (state.filteredSummaries.isEmpty) return [];
    
    // Sort by completion date
    final sortedSummaries = List<SessionSummary>.from(state.filteredSummaries)
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));
    
    return sortedSummaries.asMap().entries.map((entry) {
      final index = entry.key;
      final summary = entry.value;
      return ChartData(
        x: index.toDouble(),
        y: summary.averageTimePerQuestion.inSeconds.toDouble(),
        label: '${summary.completedAt.day}/${summary.completedAt.month}',
      );
    }).toList();
  }

  List<BarChartData> get attemptVolumeByDayData {
    if (state.filteredSummaries.isEmpty) return [];
    
    // Group summaries by date
    final Map<String, int> dailyCounts = {};
    for (final summary in state.filteredSummaries) {
      final dateKey = '${summary.completedAt.year}-${summary.completedAt.month.toString().padLeft(2, '0')}-${summary.completedAt.day.toString().padLeft(2, '0')}';
      dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
    }
    
    // Convert to chart data
    final sortedDates = dailyCounts.keys.toList()..sort();
    return sortedDates.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      final count = dailyCounts[date]!;
      
      // Format date for display
      final dateParts = date.split('-');
      final displayDate = '${dateParts[2]}/${dateParts[1]}';
      
      return BarChartData(
        x: index.toDouble(),
        y: count.toDouble(),
        label: displayDate,
      );
    }).toList();
  }


  Future<void> refresh() async {
    await _loadData();
  }
}

class ChartData {
  final double x;
  final double y;
  final String label;

  const ChartData({
    required this.x,
    required this.y,
    required this.label,
  });
}

class BarChartData {
  final double x;
  final double y;
  final String label;

  const BarChartData({
    required this.x,
    required this.y,
    required this.label,
  });
}

// Provider for the StatsViewModel
final statsViewModelProvider = StateNotifierProvider<StatsViewModel, StatsState>((ref) {
  final localStorage = LocalStorageService();
  return StatsViewModel(localStorage: localStorage);
});
