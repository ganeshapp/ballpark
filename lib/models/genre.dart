/// Enum representing different types of mental math problems
/// used in consulting-style calculations
enum Genre {
  /// Basic arithmetic operations
  addition,
  subtraction,
  multiplication,
  division,
  
  /// Percentage calculations
  percentages,
  reversePercentages,
  
  /// Ratio and fraction operations
  ratiosAndFractions,
  
  /// Growth and financial calculations
  growthRate,
  compounding,
  breakeven,
  
  /// Statistical calculations
  weightedAverage,
  
  /// Unit conversions and scaling
  scalingAndConversion,
}

/// Extension to provide display names and descriptions for genres
extension GenreExtension on Genre {
  /// Returns the display name for the genre
  String get displayName {
    switch (this) {
      case Genre.addition:
        return 'Addition';
      case Genre.subtraction:
        return 'Subtraction';
      case Genre.multiplication:
        return 'Multiplication';
      case Genre.division:
        return 'Division';
      case Genre.percentages:
        return 'Percentages';
      case Genre.ratiosAndFractions:
        return 'Ratios & Fractions';
      case Genre.reversePercentages:
        return 'Reverse Percentages';
      case Genre.growthRate:
        return 'Growth Rate';
      case Genre.compounding:
        return 'Compounding';
      case Genre.breakeven:
        return 'Breakeven';
      case Genre.weightedAverage:
        return 'Weighted Average';
      case Genre.scalingAndConversion:
        return 'Scaling & Conversion';
    }
  }
  
  /// Returns a brief description of what this genre covers
  String get description {
    switch (this) {
      case Genre.addition:
        return 'Basic addition operations';
      case Genre.subtraction:
        return 'Basic subtraction operations';
      case Genre.multiplication:
        return 'Basic multiplication operations';
      case Genre.division:
        return 'Basic division operations';
      case Genre.percentages:
        return 'Percentage calculations and conversions';
      case Genre.ratiosAndFractions:
        return 'Ratio calculations and fraction operations';
      case Genre.reversePercentages:
        return 'Working backwards from percentages';
      case Genre.growthRate:
        return 'Growth rate and CAGR calculations';
      case Genre.compounding:
        return 'Compound interest and growth';
      case Genre.breakeven:
        return 'Breakeven point calculations';
      case Genre.weightedAverage:
        return 'Weighted average calculations';
      case Genre.scalingAndConversion:
        return 'Unit conversions and scaling operations';
    }
  }
  
  /// Returns the difficulty level (1-3) for this genre
  int get difficultyLevel {
    switch (this) {
      case Genre.addition:
      case Genre.subtraction:
        return 1;
      case Genre.multiplication:
      case Genre.division:
      case Genre.percentages:
        return 2;
      case Genre.ratiosAndFractions:
      case Genre.reversePercentages:
      case Genre.growthRate:
      case Genre.compounding:
      case Genre.breakeven:
      case Genre.weightedAverage:
      case Genre.scalingAndConversion:
        return 3;
    }
  }
}
