import 'dart:math';
import '../models/problem.dart';
import '../models/genre.dart';

class ProblemGeneratorService {
  static final Random _random = Random();

  Problem generateProblem(Genre genre) {
    switch (genre) {
      case Genre.addition:
        return _generateAdditionProblem();
      case Genre.subtraction:
        return _generateSubtractionProblem();
      case Genre.multiplication:
        return _generateMultiplicationProblem();
      case Genre.division:
        return _generateDivisionProblem();
      case Genre.percentages:
        return _generatePercentageProblem();
      case Genre.ratiosAndFractions:
        return _generateRatioProblem();
      case Genre.reversePercentages:
        return _generateReversePercentageProblem();
      case Genre.growthRate:
        return _generateGrowthRateProblem();
      case Genre.compounding:
        return _generateCompoundingProblem();
      case Genre.breakeven:
        return _generateBreakevenProblem();
      case Genre.weightedAverage:
        return _generateWeightedAverageProblem();
      case Genre.scalingAndConversion:
        return _generateScalingProblem();
    }
  }

  Problem _generateAdditionProblem() {
    // Vary the magnitude of numbers - include billions now
    final magnitudes = [
      (1000, 10000),       // Thousands
      (10000, 100000),     // Tens of thousands
      (100000, 1000000),   // Hundreds of thousands
      (1000000, 10000000), // Millions
      (10000000, 100000000), // Tens of millions
      (100000000, 1000000000), // Hundreds of millions
      (1000000000, 4000000000), // Billions (capped to avoid overflow)
    ];
    
    final mag1 = magnitudes[_random.nextInt(magnitudes.length)];
    int a = _generateNumberInRange(mag1.$1, mag1.$2);
    int b;
    
    // 50% chance: same magnitude, 50% chance: different but close magnitudes
    if (_random.nextBool()) {
      // Same magnitude
      b = _generateNumberInRange(mag1.$1, mag1.$2);
    } else {
      // Different magnitude - ensure smaller is at least 15% of larger to make it meaningful
      final isALarger = _random.nextBool();
      if (isALarger) {
        // b should be 15-80% of a
        final minB = (a * 0.15).toInt();
        final maxB = (a * 0.8).toInt();
        b = _generateNumberInRange(minB, maxB);
      } else {
        // a should be 15-80% of b - so b should be larger
        final minB = (a / 0.8).toInt().clamp(a + 1, 10000000000);
        final maxB = (a / 0.15).toInt().clamp(minB, 10000000000);
        if (minB < maxB) {
          b = _generateNumberInRange(minB, maxB);
        } else {
          // Fallback to same magnitude if range calculation fails
          b = _generateNumberInRange(mag1.$1, mag1.$2);
        }
      }
    }
    
    final answer = a + b;

    return Problem(
      questionText: '${_formatNumber(a)} + ${_formatNumber(b)}',
      actualAnswer: answer.toDouble(),
    );
  }

  Problem _generateSubtractionProblem() {
    // Vary the magnitude of numbers - include billions
    final magnitudes = [
      (10000, 100000),     // Tens of thousands
      (100000, 1000000),   // Hundreds of thousands
      (1000000, 10000000), // Millions
      (10000000, 100000000), // Tens of millions
      (100000000, 1000000000), // Hundreds of millions
      (1000000000, 4000000000), // Billions (capped to avoid overflow)
    ];
    
    final mag = magnitudes[_random.nextInt(magnitudes.length)];
    int a = _generateNumberInRange(mag.$1, mag.$2);
    int b;
    
    // 50% chance: same magnitude, 50% chance: different but meaningful
    if (_random.nextBool()) {
      // Same magnitude - b should be less than a
      final minB = mag.$1 ~/ 2;
      final maxB = (a - (a ~/ 10)).clamp(minB, a - 1);
      if (minB < maxB) {
        b = _generateNumberInRange(minB, maxB);
      } else {
        b = _generateNumberInRange(minB, a - 1);
      }
    } else {
      // Different magnitude - b should be 15-80% of a to make the 10% precision matter
      final minB = (a * 0.15).toInt();
      final maxB = (a * 0.8).toInt();
      b = _generateNumberInRange(minB, maxB);
    }
    
    final answer = a - b;

    return Problem(
      questionText: '${_formatNumber(a)} - ${_formatNumber(b)}',
      actualAnswer: answer.toDouble(),
    );
  }

  Problem _generateMultiplicationProblem() {
    // Vary the magnitude of base number
    final magnitudes = [
      (10000, 100000),     // Tens of thousands
      (100000, 1000000),   // Hundreds of thousands
      (1000000, 10000000), // Millions
      (10000000, 20000000), // Tens of millions
    ];
    
    final mag = magnitudes[_random.nextInt(magnitudes.length)];
    final a = _generateNumberInRange(mag.$1, mag.$2);
    final b = _generateNumberInRange(5, 9999);
    final answer = a * b;

    return Problem(
      questionText: '${_formatNumber(a)} × ${_formatNumber(b)}',
      actualAnswer: answer.toDouble(),
    );
  }

  Problem _generateDivisionProblem() {
    // Generate dividend first
    final magnitudes = [
      (100000, 1000000),   // Hundreds of thousands
      (1000000, 10000000), // Millions
      (10000000, 100000000), // Tens of millions
    ];
    
    final mag = magnitudes[_random.nextInt(magnitudes.length)];
    final a = _generateNumberInRange(mag.$1, mag.$2);
    
    // Divisor should be 2-9999 and less than dividend
    final maxB = a ~/ 2; // Ensure result is meaningful
    final b = _generateNumberInRange(2, maxB.clamp(2, 9999));
    final answer = a / b;

    return Problem(
      questionText: '${_formatNumber(a)} ÷ ${_formatNumber(b)}',
      actualAnswer: answer,
    );
  }

  Problem _generatePercentageProblem() {
    final percentage = _generateNumberInRange(5, 95);
    // Vary magnitude: millions to hundreds of millions (not billions - exceeds int limit)
    final magnitudes = [
      (10000000, 50000000),     // 10M to 50M
      (50000000, 100000000),    // 50M to 100M
      (100000000, 500000000),   // 100M to 500M
    ];
    final mag = magnitudes[_random.nextInt(magnitudes.length)];
    final number = _generateNumberInRange(mag.$1, mag.$2);
    final answer = (number * percentage) / 100;

    return Problem(
      questionText: '$percentage% of ${_formatNumber(number)}',
      actualAnswer: answer,
    );
  }

  Problem _generateRatioProblem() {
    final a = _generateNumberInRange(100000, 10000000);
    final b = _generateNumberInRange(a + 100000, 50000000);
    final answer = (a / b) * 100;

    return Problem(
      questionText: 'What percentage is ${_formatNumber(a)} of ${_formatNumber(b)}?',
      actualAnswer: answer,
    );
  }

  Problem _generateReversePercentageProblem() {
    final percentage = _generateNumberInRange(5, 95);
    final isIncrease = _random.nextBool();
    // Vary magnitude: millions to hundreds of millions (safe integer range)
    final magnitudes = [
      (10000000, 50000000),     // 10M to 50M
      (50000000, 100000000),    // 50M to 100M
      (100000000, 500000000),   // 100M to 500M
    ];
    final mag = magnitudes[_random.nextInt(magnitudes.length)];
    final finalValue = _generateNumberInRange(mag.$1, mag.$2);
    final answer = finalValue / (1 + (isIncrease ? percentage : -percentage) / 100);

    return Problem(
      questionText: 'After a ${isIncrease ? '' : '-'}$percentage% ${isIncrease ? 'increase' : 'decrease'}, revenue is ${_formatNumber(finalValue)}. What was the original revenue?',
      actualAnswer: answer,
    );
  }

  Problem _generateGrowthRateProblem() {
    // Vary magnitude: millions to hundreds of millions (safe integer range)
    final magnitudes = [
      (10000000, 50000000),     // 10M to 50M
      (50000000, 100000000),    // 50M to 100M
      (100000000, 500000000),   // 100M to 500M
    ];
    final mag = magnitudes[_random.nextInt(magnitudes.length)];
    final oldValue = _generateNumberInRange(mag.$1, mag.$2);
    final growthRate = _generateNumberInRange(5, 200);
    final newValue = oldValue * (1 + growthRate / 100);
    // Answer stored as percentage (e.g., 50 for 50% growth)
    // Users can enter either "0.5" or "50%" and both will be accepted
    final answer = growthRate.toDouble();

    return Problem(
      questionText: 'If sales went from ${_formatNumber(oldValue)} to ${_formatNumber(newValue.toInt())}, what was the growth rate?',
      actualAnswer: answer,
    );
  }

  Problem _generateCompoundingProblem() {
    final rate = _generateNumberInRange(5, 20);
    final answer = 72.0 / rate;

    return Problem(
      questionText: 'If a market grows at $rate% annually, how many years will it take to double?',
      actualAnswer: answer,
    );
  }

  Problem _generateBreakevenProblem() {
    final fixedCosts = _generateNumberInRange(1000000, 100000000);
    final price = _generateNumberInRange(100, 1000);
    final variableCosts = _generateNumberInRange(50, price - 10);
    final answer = fixedCosts / (price - variableCosts);

    return Problem(
      questionText: 'Fixed Cost: \$${_formatNumber(fixedCosts)}\nSales Price: \$$price\nVariable Cost: \$$variableCosts',
      actualAnswer: answer,
    );
  }

  Problem _generateWeightedAverageProblem() {
    final weight1 = _generateNumberInRange(20, 80);
    final weight2 = 100 - weight1;
    final value1 = _generateNumberInRange(50, 200);
    final value2 = _generateNumberInRange(100, 500);
    final answer = (weight1 * value1 + weight2 * value2) / 100;

    return Problem(
      questionText: 'A company sells $weight1% of units for \$$value1 and $weight2% for \$$value2. What is the weighted average price?',
      actualAnswer: answer,
    );
  }

  Problem _generateScalingProblem() {
    final units = _generateNumberInRange(1000, 100000);
    final timeUnit = ['day', 'week', 'month'][_random.nextInt(3)];
    final multiplier = timeUnit == 'day' ? 360 : timeUnit == 'week' ? 50 : 12;
    final answer = units * multiplier;

    return Problem(
      questionText: 'A factory produces ${_formatNumber(units)} units per $timeUnit. How many does it produce per year?',
      actualAnswer: answer.toDouble(),
    );
  }

  int _generateNumberInRange(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  String _formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}