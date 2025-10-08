import 'package:flutter_test/flutter_test.dart';
import 'package:ballpark/services/problem_generator_service.dart';
import 'package:ballpark/models/problem.dart';
import 'package:ballpark/models/genre.dart';

void main() {
  group('ProblemGeneratorService', () {
    late ProblemGeneratorService service;
    
    setUp(() {
      service = ProblemGeneratorService();
    });
    
    group('Addition Problems', () {
      test('should generate valid addition problems', () {
        for (int i = 0; i < 100; i++) {
          final problem = service.generateProblem(Genre.addition);
          
          // Verify the problem structure
          expect(problem, isA<Problem>());
          expect(problem.questionText, isNotEmpty);
          expect(problem.actualAnswer, isA<double>());
          
          // Verify question format
          expect(problem.questionText, startsWith('What is '));
          expect(problem.questionText, endsWith('?'));
          expect(problem.questionText, contains(' + '));
          
          // Verify numbers are in the expected range
          final numbers = _extractNumbersFromQuestion(problem.questionText);
          expect(numbers, hasLength(2));
          
          for (final number in numbers) {
            expect(number, greaterThanOrEqualTo(100000));
            expect(number, lessThanOrEqualTo(500000000));
          }
          
          // Verify the answer is correct
          final expectedAnswer = numbers[0] + numbers[1];
          expect(problem.actualAnswer, equals(expectedAnswer));
        }
      });
      
      test('should generate different problems on multiple calls', () {
        final problems = <String>{};
        
        for (int i = 0; i < 50; i++) {
          final problem = service.generateProblem(Genre.addition);
          problems.add(problem.questionText);
        }
        
        // Should have generated some variety (not all identical)
        expect(problems.length, greaterThan(1));
      });
      
      test('should format numbers with commas', () {
        final problem = service.generateProblem(Genre.addition);
        
        // Check that large numbers are formatted with commas
        expect(problem.questionText, contains(','));
      });
    });
    
    group('Subtraction Problems', () {
      test('should generate valid subtraction problems with A > B', () {
        for (int i = 0; i < 100; i++) {
          final problem = service.generateProblem(Genre.subtraction);
          
          // Verify the problem structure
          expect(problem, isA<Problem>());
          expect(problem.questionText, isNotEmpty);
          expect(problem.actualAnswer, isA<double>());
          
          // Verify question format
          expect(problem.questionText, startsWith('What is '));
          expect(problem.questionText, endsWith('?'));
          expect(problem.questionText, contains(' - '));
          
          // Verify numbers are in the expected range
          final numbers = _extractNumbersFromQuestion(problem.questionText);
          expect(numbers, hasLength(2));
          
          for (final number in numbers) {
            expect(number, greaterThanOrEqualTo(100000));
            expect(number, lessThanOrEqualTo(500000000));
          }
          
          // CRITICAL: Verify A > B constraint
          expect(numbers[0], greaterThan(numbers[1]), 
            reason: 'First number (A) must be greater than second number (B)');
          
          // Verify the answer is correct
          final expectedAnswer = numbers[0] - numbers[1];
          expect(problem.actualAnswer, equals(expectedAnswer));
          expect(problem.actualAnswer, greaterThan(0), 
            reason: 'Subtraction result should be positive');
        }
      });
      
      test('should always ensure positive results', () {
        for (int i = 0; i < 100; i++) {
          final problem = service.generateProblem(Genre.subtraction);
          expect(problem.actualAnswer, greaterThan(0),
            reason: 'All subtraction results should be positive');
        }
      });
      
      test('should generate different problems on multiple calls', () {
        final problems = <String>{};
        
        for (int i = 0; i < 50; i++) {
          final problem = service.generateProblem(Genre.subtraction);
          problems.add(problem.questionText);
        }
        
        // Should have generated some variety (not all identical)
        expect(problems.length, greaterThan(1));
      });
      
      test('should format numbers with commas', () {
        final problem = service.generateProblem(Genre.subtraction);
        
        // Check that large numbers are formatted with commas
        expect(problem.questionText, contains(','));
      });
    });
    
    group('Multiplication Problems', () {
      test('should generate valid multiplication problems', () {
        for (int i = 0; i < 50; i++) {
          final problem = service.generateProblem(Genre.multiplication);
          
          expect(problem, isA<Problem>());
          expect(problem.questionText, startsWith('What is '));
          expect(problem.questionText, endsWith('?'));
          expect(problem.questionText, contains(' x '));
          
          final numbers = _extractNumbersFromQuestion(problem.questionText);
          expect(numbers, hasLength(2));
          
          // A should be 100k-20M, B should be 2-19
          expect(numbers[0], greaterThanOrEqualTo(100000));
          expect(numbers[0], lessThanOrEqualTo(20000000));
          expect(numbers[1], greaterThanOrEqualTo(2));
          expect(numbers[1], lessThanOrEqualTo(19));
          
          // Verify answer
          expect(problem.actualAnswer, equals((numbers[0] * numbers[1]).toDouble()));
        }
      });
    });
    
    group('Division Problems', () {
      test('should generate valid division problems with clean results', () {
        for (int i = 0; i < 50; i++) {
          final problem = service.generateProblem(Genre.division);
          
          expect(problem, isA<Problem>());
          expect(problem.questionText, startsWith('What is '));
          expect(problem.questionText, endsWith('?'));
          expect(problem.questionText, contains(' / '));
          
          final numbers = _extractNumbersFromQuestion(problem.questionText);
          expect(numbers, hasLength(2));
          
          // Verify clean division (no remainder)
          expect(numbers[0] % numbers[1], equals(0));
          
          // Verify answer
          expect(problem.actualAnswer, equals(numbers[0] / numbers[1]));
        }
      });
    });
    
    group('Percentage Problems', () {
      test('should generate valid percentage problems', () {
        for (int i = 0; i < 50; i++) {
          final problem = service.generateProblem(Genre.percentages);
          
          expect(problem, isA<Problem>());
          expect(problem.questionText, startsWith('What is '));
          expect(problem.questionText, endsWith('?'));
          expect(problem.questionText, contains('% of \$'));
          
          // Extract percentage and number from question
          final parts = problem.questionText.split('% of \$');
          final percentage = int.parse(parts[0].split(' ').last);
          final number = int.parse(parts[1].replaceAll(',', '').replaceAll('?', ''));
          
          expect(percentage, greaterThanOrEqualTo(5));
          expect(percentage, lessThanOrEqualTo(95));
          expect(number, greaterThanOrEqualTo(10000000));
          expect(number, lessThanOrEqualTo(500000000000));
          
          // Verify answer
          expect(problem.actualAnswer, equals((number * percentage) / 100));
        }
      });
    });
    
    group('Ratios and Fractions Problems', () {
      test('should generate valid ratio problems with B > A', () {
        for (int i = 0; i < 50; i++) {
          final problem = service.generateProblem(Genre.ratiosAndFractions);
          
          expect(problem, isA<Problem>());
          expect(problem.questionText, startsWith('What percentage is '));
          expect(problem.questionText, endsWith('?'));
          expect(problem.questionText, contains(' of '));
          
          final numbers = _extractNumbersFromQuestion(problem.questionText);
          expect(numbers, hasLength(2));
          
          // Verify B > A constraint
          expect(numbers[1], greaterThan(numbers[0]));
          
          // Verify answer is decimal
          expect(problem.actualAnswer, equals(numbers[0] / numbers[1]));
          expect(problem.actualAnswer, lessThan(1.0));
        }
      });
    });
    
    group('Reverse Percentage Problems', () {
      test('should generate valid reverse percentage problems', () {
        for (int i = 0; i < 50; i++) {
          final problem = service.generateProblem(Genre.reversePercentages);
          
          expect(problem, isA<Problem>());
          expect(problem.questionText, startsWith('After a '));
          expect(problem.questionText, endsWith('?'));
          expect(problem.questionText, anyOf([contains('% increase'), contains('% decrease')]));
          expect(problem.questionText, contains('revenue is \$'));
          
          // Extract percentage from question
          final percentageMatch = RegExp(r'(\d+)% (increase|decrease)').firstMatch(problem.questionText);
          expect(percentageMatch, isNotNull);
          final percentage = int.parse(percentageMatch!.group(1)!);
          
          expect(percentage, greaterThanOrEqualTo(5));
          expect(percentage, lessThanOrEqualTo(50));
        }
      });
    });
    
    group('Growth Rate Problems', () {
      test('should generate valid growth rate problems', () {
        for (int i = 0; i < 50; i++) {
          final problem = service.generateProblem(Genre.growthRate);
          
          expect(problem, isA<Problem>());
          expect(problem.questionText, startsWith('If sales went from \$'));
          expect(problem.questionText, endsWith('?'));
          expect(problem.questionText, contains(' to \$'));
          expect(problem.questionText, contains('what was the growth rate'));
          
          // Extract old value
          final parts = problem.questionText.split(' to \$');
          final oldValue = int.parse(parts[0].split('\$').last.replaceAll(',', ''));
          
          expect(oldValue, greaterThanOrEqualTo(1000000));
          expect(oldValue, lessThanOrEqualTo(100000000));
          
          // Answer should be decimal growth rate
          expect(problem.actualAnswer, isA<double>());
        }
      });
    });
    
    group('Compounding Problems', () {
      test('should generate valid compounding problems using rule of 72', () {
        for (int i = 0; i < 50; i++) {
          final problem = service.generateProblem(Genre.compounding);
          
          expect(problem, isA<Problem>());
          expect(problem.questionText, startsWith('If a market grows at '));
          expect(problem.questionText, endsWith('?'));
          expect(problem.questionText, contains('% annually'));
          expect(problem.questionText, contains('how many years will it take to double'));
          
          // Extract rate from question
          final rateMatch = RegExp(r'(\d+)% annually').firstMatch(problem.questionText);
          expect(rateMatch, isNotNull);
          final rate = int.parse(rateMatch!.group(1)!);
          
          expect(rate, greaterThanOrEqualTo(2));
          expect(rate, lessThanOrEqualTo(20));
          
          // Verify answer using rule of 72
          expect(problem.actualAnswer, equals(72.0 / rate));
        }
      });
    });
    
    group('Breakeven Problems', () {
      test('should generate valid breakeven problems with P > VC', () {
        for (int i = 0; i < 50; i++) {
          final problem = service.generateProblem(Genre.breakeven);
          
          expect(problem, isA<Problem>());
          expect(problem.questionText, startsWith('With fixed costs of \$'));
          expect(problem.questionText, endsWith('?'));
          expect(problem.questionText, contains('a price of \$'));
          expect(problem.questionText, contains('variable costs of \$'));
          expect(problem.questionText, contains('what is the breakeven volume'));
          
          // Extract values from question
          final fixedCostsMatch = RegExp(r'fixed costs of \$([0-9,]+)').firstMatch(problem.questionText);
          final priceMatch = RegExp(r'price of \$([0-9,]+)').firstMatch(problem.questionText);
          final variableCostMatch = RegExp(r'variable costs of \$([0-9,]+)').firstMatch(problem.questionText);
          
          expect(fixedCostsMatch, isNotNull);
          expect(priceMatch, isNotNull);
          expect(variableCostMatch, isNotNull);
          
          final fixedCosts = int.parse(fixedCostsMatch!.group(1)!.replaceAll(',', ''));
          final price = int.parse(priceMatch!.group(1)!.replaceAll(',', ''));
          final variableCost = int.parse(variableCostMatch!.group(1)!.replaceAll(',', ''));
          
          // Verify P > VC constraint
          expect(price, greaterThan(variableCost));
          
          // Verify answer calculation
          expect(problem.actualAnswer, equals(fixedCosts / (price - variableCost)));
        }
      });
    });
    
    group('Weighted Average Problems', () {
      test('should generate valid weighted average problems', () {
        for (int i = 0; i < 50; i++) {
          final problem = service.generateProblem(Genre.weightedAverage);
          
          expect(problem, isA<Problem>());
          expect(problem.questionText, startsWith('A company sells '));
          expect(problem.questionText, endsWith('?'));
          expect(problem.questionText, contains('% of units for \$'));
          expect(problem.questionText, contains(' and '));
          expect(problem.questionText, contains('What is the weighted average price'));
          
          // Extract weights and values
          final w1Match = RegExp(r'(\d+)% of units').firstMatch(problem.questionText);
          final v1Match = RegExp(r'for \$([0-9,]+) and').firstMatch(problem.questionText);
          final w2Match = RegExp(r'and (\d+)% for').firstMatch(problem.questionText);
          final v2Match = RegExp(r'for \$([0-9,]+)\. What').firstMatch(problem.questionText);
          
          expect(w1Match, isNotNull);
          expect(v1Match, isNotNull);
          expect(w2Match, isNotNull);
          expect(v2Match, isNotNull);
          
          final w1 = int.parse(w1Match!.group(1)!);
          final v1 = int.parse(v1Match!.group(1)!.replaceAll(',', ''));
          final w2 = int.parse(w2Match!.group(1)!);
          final v2 = int.parse(v2Match!.group(1)!.replaceAll(',', ''));
          
          // Verify weights sum to 100%
          expect(w1 + w2, equals(100));
          
          // Verify answer calculation
          expect(problem.actualAnswer, equals((w1 * v1 + w2 * v2) / 100));
        }
      });
    });
    
    group('Scaling and Conversion Problems', () {
      test('should generate valid scaling problems', () {
        for (int i = 0; i < 50; i++) {
          final problem = service.generateProblem(Genre.scalingAndConversion);
          
          expect(problem, isA<Problem>());
          expect(problem.questionText, startsWith('A factory produces '));
          expect(problem.questionText, endsWith('?'));
          expect(problem.questionText, contains(' units per '));
          expect(problem.questionText, contains('How many does it produce per year'));
          
          // Extract units and time unit
          final unitsMatch = RegExp(r'produces ([0-9,]+) units').firstMatch(problem.questionText);
          final timeUnitMatch = RegExp(r'per (day|week|month)\.').firstMatch(problem.questionText);
          
          expect(unitsMatch, isNotNull);
          expect(timeUnitMatch, isNotNull);
          
          final units = int.parse(unitsMatch!.group(1)!.replaceAll(',', ''));
          final timeUnit = timeUnitMatch!.group(1)!;
          
          expect(units, greaterThanOrEqualTo(100));
          expect(units, lessThanOrEqualTo(10000));
          expect(['day', 'week', 'month'], contains(timeUnit));
          
          // Verify answer based on time unit
          final expectedMultiplier = timeUnit == 'day' ? 360 : (timeUnit == 'week' ? 50 : 12);
          expect(problem.actualAnswer, equals((units * expectedMultiplier).toDouble()));
        }
      });
    });
  });
}

/// Helper function to extract numbers from a question string
/// Assumes format: "What is {number1} + {number2}?" or "What is {number1} - {number2}?"
List<int> _extractNumbersFromQuestion(String question) {
  // Remove "What is " and "?" and split by the operator
  final cleanQuestion = question
      .replaceFirst('What is ', '')
      .replaceFirst('?', '');
  
  final parts = cleanQuestion.split(RegExp(r' [+\-] '));
  expect(parts, hasLength(2), reason: 'Question should have exactly two numbers');
  
  // Parse numbers, removing commas
  final number1 = int.parse(parts[0].replaceAll(',', ''));
  final number2 = int.parse(parts[1].replaceAll(',', ''));
  
  return [number1, number2];
}
