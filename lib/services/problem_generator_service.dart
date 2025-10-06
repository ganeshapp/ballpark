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
    // Vary the magnitude of numbers
    final magnitudes = [
      (1000, 10000),       // Thousands
      (10000, 100000),     // Tens of thousands
      (100000, 1000000),   // Hundreds of thousands
      (1000000, 10000000), // Millions
      (10000000, 100000000), // Tens of millions
      (100000000, 500000000), // Hundreds of millions
    ];
    
    final mag1 = magnitudes[_random.nextInt(magnitudes.length)];
    final mag2 = magnitudes[_random.nextInt(magnitudes.length)];
    
    final a = _generateNumberInRange(mag1.$1, mag1.$2);
    final b = _generateNumberInRange(mag2.$1, mag2.$2);
    final answer = a + b;

    return Problem(
      questionText: 'What is ${_formatNumber(a)} + ${_formatNumber(b)}?',
      actualAnswer: answer.toDouble(),
    );
  }

  Problem _generateSubtractionProblem() {
    // Vary the magnitude of numbers
    final magnitudes = [
      (10000, 100000),     // Tens of thousands
      (100000, 1000000),   // Hundreds of thousands
      (1000000, 10000000), // Millions
      (10000000, 100000000), // Tens of millions
      (100000000, 500000000), // Hundreds of millions
    ];
    
    final mag = magnitudes[_random.nextInt(magnitudes.length)];
    final a = _generateNumberInRange(mag.$1, mag.$2);
    final b = _generateNumberInRange(mag.$1 ~/ 2, a - 1000);
    final answer = a - b;

    return Problem(
      questionText: 'What is ${_formatNumber(a)} - ${_formatNumber(b)}?',
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
    final b = _generateNumberInRange(2, 19);
    final answer = a * b;

    return Problem(
      questionText: 'What is ${_formatNumber(a)} × ${_formatNumber(b)}?',
      actualAnswer: answer.toDouble(),
    );
  }

  Problem _generateDivisionProblem() {
    final b = _generateNumberInRange(2, 20);
    final answer = _generateNumberInRange(10000, 1000000);
    final a = answer * b;

    return Problem(
      questionText: 'What is ${_formatNumber(a)} ÷ ${_formatNumber(b)}?',
      actualAnswer: answer.toDouble(),
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
      questionText: 'What is $percentage% of ${_formatNumber(number)}?',
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
      questionText: 'With fixed costs of ${_formatNumber(fixedCosts)}, a price of \$$price, and variable costs of \$$variableCosts, what is the breakeven volume?',
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