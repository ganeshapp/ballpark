import 'dart:math';
import '../models/problem.dart';
import '../models/genre.dart';

/// Service responsible for generating mental math problems based on genre
class ProblemGeneratorService {
  static final Random _random = Random();
  
  /// Generates a problem based on the specified genre
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
        return _generatePercentagesProblem();
      case Genre.ratiosAndFractions:
        return _generateRatiosAndFractionsProblem();
      case Genre.reversePercentages:
        return _generateReversePercentagesProblem();
      case Genre.growthRate:
        return _generateGrowthRateProblem();
      case Genre.compounding:
        return _generateCompoundingProblem();
      case Genre.breakeven:
        return _generateBreakevenProblem();
      case Genre.weightedAverage:
        return _generateWeightedAverageProblem();
      case Genre.scalingAndConversion:
        return _generateScalingAndConversionProblem();
    }
  }
  
  /// Generates an addition problem with two large numbers
  Problem _generateAdditionProblem() {
    final a = _generateLargeNumber();
    final b = _generateLargeNumber();
    final answer = a + b;
    
    return Problem(
      questionText: 'What is ${_formatNumber(a)} + ${_formatNumber(b)}?',
      actualAnswer: answer,
    );
  }
  
  /// Generates a subtraction problem with two large numbers
  /// Ensures A > B to avoid negative results
  Problem _generateSubtractionProblem() {
    final a = _generateLargeNumber();
    final b = _generateLargeNumber();
    
    // Ensure A > B by swapping if necessary
    final larger = a > b ? a : b;
    final smaller = a > b ? b : a;
    
    final answer = larger - smaller;
    
    return Problem(
      questionText: 'What is ${_formatNumber(larger)} - ${_formatNumber(smaller)}?',
      actualAnswer: answer,
    );
  }
  
  /// Generates a random large number between 100,000 and 500,000,000
  int _generateLargeNumber() {
    const minValue = 100000;
    const maxValue = 500000000;
    return minValue + _random.nextInt(maxValue - minValue + 1);
  }
  
  /// Generates a multiplication problem
  Problem _generateMultiplicationProblem() {
    final a = _generateNumberInRange(100000, 20000000); // 100k-20M
    final b = _generateNumberInRange(2, 19); // 2-19
    final answer = a * b;
    
    return Problem(
      questionText: 'What is ${_formatNumber(a)} x ${_formatNumber(b)}?',
      actualAnswer: answer.toDouble(),
    );
  }
  
  /// Generates a division problem with clean results
  Problem _generateDivisionProblem() {
    final b = _generateNumberInRange(2, 100); // denominator
    final quotient = _generateNumberInRange(1000, 100000); // quotient
    final a = b * quotient; // numerator (ensures clean division)
    final answer = a / b;
    
    return Problem(
      questionText: 'What is ${_formatNumber(a)} / ${_formatNumber(b)}?',
      actualAnswer: answer,
    );
  }
  
  /// Generates a percentage problem
  Problem _generatePercentagesProblem() {
    final percentage = _generateNumberInRange(5, 95); // 5-95%
    final number = _generateNumberInRange(10000000, 500000000000); // $10M-$500B
    final answer = (number * percentage) / 100;
    
    return Problem(
      questionText: 'What is $percentage% of \$${_formatNumber(number)}?',
      actualAnswer: answer,
    );
  }
  
  /// Generates a ratios and fractions problem
  Problem _generateRatiosAndFractionsProblem() {
    final b = _generateNumberInRange(100000, 10000000); // larger number
    final a = _generateNumberInRange(10000, b - 1); // smaller number, ensuring B > A
    final answer = a / b; // decimal result
    
    return Problem(
      questionText: 'What percentage is ${_formatNumber(a)} of ${_formatNumber(b)}?',
      actualAnswer: answer,
    );
  }
  
  /// Generates a reverse percentage problem
  Problem _generateReversePercentagesProblem() {
    final percentage = _generateNumberInRange(5, 50); // 5-50%
    final isIncrease = _random.nextBool();
    final newValue = _generateNumberInRange(1000000, 1000000000);
    
    // Calculate original value: newValue = original * (1 ± percentage/100)
    final multiplier = isIncrease ? (1 + percentage / 100) : (1 - percentage / 100);
    final originalValue = newValue / multiplier;
    final answer = originalValue;
    
    final changeType = isIncrease ? 'increase' : 'decrease';
    return Problem(
      questionText: 'After a $percentage% $changeType, revenue is \$${_formatNumber(newValue)}. What was the original revenue?',
      actualAnswer: answer,
    );
  }
  
  /// Generates a growth rate problem
  Problem _generateGrowthRateProblem() {
    final oldValue = _generateNumberInRange(1000000, 100000000);
    final growthRate = (_random.nextDouble() - 0.5) * 100; // -50% to +50%
    final newValue = oldValue * (1 + growthRate / 100);
    final answer = growthRate / 100; // decimal growth rate
    
    return Problem(
      questionText: 'If sales went from \$${_formatNumber(oldValue)} to \$${_formatNumber(newValue.round())}, what was the growth rate?',
      actualAnswer: answer,
    );
  }
  
  /// Generates a compounding problem
  Problem _generateCompoundingProblem() {
    final rate = _generateNumberInRange(2, 20); // 2-20% annual growth
    final answer = 72.0 / rate; // Rule of 72
    
    return Problem(
      questionText: 'If a market grows at $rate% annually, how many years will it take to double?',
      actualAnswer: answer,
    );
  }
  
  /// Generates a breakeven problem
  Problem _generateBreakevenProblem() {
    final fixedCosts = _generateNumberInRange(100000, 10000000);
    final price = _generateNumberInRange(10, 1000);
    final variableCost = _generateNumberInRange(1, price - 1); // Ensure P > VC
    final answer = fixedCosts / (price - variableCost);
    
    return Problem(
      questionText: 'With fixed costs of \$${_formatNumber(fixedCosts)}, a price of \$${_formatNumber(price)}, and variable costs of \$${_formatNumber(variableCost)}, what is the breakeven volume?',
      actualAnswer: answer,
    );
  }
  
  /// Generates a weighted average problem
  Problem _generateWeightedAverageProblem() {
    final w1 = _generateNumberInRange(20, 80); // 20-80%
    final w2 = 100 - w1; // Ensure weights sum to 100%
    final v1 = _generateNumberInRange(10, 1000);
    final v2 = _generateNumberInRange(10, 1000);
    final answer = (w1 * v1 + w2 * v2) / 100;
    
    return Problem(
      questionText: 'A company sells $w1% of units for \$${_formatNumber(v1)} and $w2% for \$${_formatNumber(v2)}. What is the weighted average price?',
      actualAnswer: answer,
    );
  }
  
  /// Generates a scaling and conversion problem
  Problem _generateScalingAndConversionProblem() {
    final units = _generateNumberInRange(100, 10000);
    final timeUnits = ['day', 'week', 'month'];
    final multipliers = [360, 50, 12];
    
    final timeIndex = _random.nextInt(timeUnits.length);
    final timeUnit = timeUnits[timeIndex];
    final multiplier = multipliers[timeIndex];
    
    final answer = units * multiplier;
    
    return Problem(
      questionText: 'A factory produces ${_formatNumber(units)} units per $timeUnit. How many does it produce per year?',
      actualAnswer: answer.toDouble(),
    );
  }
  
  /// Generates a random number within a specified range
  int _generateNumberInRange(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }
  
  /// Formats a number with commas for better readability
  String _formatNumber(int number) {
    final numberString = number.toString();
    final buffer = StringBuffer();
    
    for (int i = 0; i < numberString.length; i++) {
      if (i > 0 && (numberString.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(numberString[i]);
    }
    
    return buffer.toString();
  }
}
