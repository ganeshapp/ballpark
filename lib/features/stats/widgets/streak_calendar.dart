import 'package:flutter/material.dart';
import '../../../models/session_summary.dart';

class StreakCalendar extends StatelessWidget {
  final List<SessionSummary> summaries;

  const StreakCalendar({super.key, required this.summaries});

  @override
  Widget build(BuildContext context) {
    // Get last 30 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thirtyDaysAgo = today.subtract(const Duration(days: 29));
    
    // Create a map of dates with sessions
    final sessionsPerDay = <DateTime, int>{};
    for (var summary in summaries) {
      final date = DateTime(
        summary.completedAt.year,
        summary.completedAt.month,
        summary.completedAt.day,
      );
      if (date.isAfter(thirtyDaysAgo.subtract(const Duration(days: 1)))) {
        sessionsPerDay[date] = (sessionsPerDay[date] ?? 0) + 1;
      }
    }
    
    // Calculate current streak
    int currentStreak = 0;
    var checkDate = today;
    while (sessionsPerDay.containsKey(checkDate)) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.pink.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange.shade600, size: 28),
              const SizedBox(width: 8),
              Text(
                'Streak Calendar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Current Streak: $currentStreak ${currentStreak == 1 ? 'day' : 'days'}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Calendar grid
          LayoutBuilder(
            builder: (context, constraints) {
              final cellSize = (constraints.maxWidth - 48) / 7; // 7 days per row, with padding
              
              return Column(
                children: [
                  // Day labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                      return SizedBox(
                        width: cellSize,
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  
                  // Calendar cells
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: List.generate(30, (index) {
                      final date = thirtyDaysAgo.add(Duration(days: index));
                      final hasSession = sessionsPerDay.containsKey(date);
                      final sessionCount = sessionsPerDay[date] ?? 0;
                      final isToday = date == today;
                      
                      return _buildCalendarCell(
                        date,
                        hasSession,
                        sessionCount,
                        isToday,
                        cellSize,
                      );
                    }),
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.grey.shade200, 'No activity'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.orange.shade300, '1-2 sessions'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.orange.shade500, '3+ sessions'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCell(DateTime date, bool hasSession, int sessionCount, bool isToday, double size) {
    Color cellColor;
    if (!hasSession) {
      cellColor = Colors.grey.shade200;
    } else if (sessionCount <= 2) {
      cellColor = Colors.orange.shade300;
    } else {
      cellColor = Colors.orange.shade500;
    }
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(6),
        border: isToday ? Border.all(color: Colors.orange.shade800, width: 2) : null,
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: hasSession ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

