enum Genre {
  addition,
  subtraction,
  multiplication,
  division,
  percentages,
  ratiosAndFractions,
  reversePercentages,
  growthRate,
  compounding,
  breakeven,
  weightedAverage,
  scalingAndConversion,
}

extension GenreExtension on Genre {
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
        return 'Breakeven Volume';
      case Genre.weightedAverage:
        return 'Weighted Average';
      case Genre.scalingAndConversion:
        return 'Scaling & Conversion';
    }
  }

  String get description {
    switch (this) {
      case Genre.addition:
        return 'Large number addition';
      case Genre.subtraction:
        return 'Large number subtraction';
      case Genre.multiplication:
        return 'Large number multiplication';
      case Genre.division:
        return 'Division problems';
      case Genre.percentages:
        return 'Percentage calculations';
      case Genre.ratiosAndFractions:
        return 'Ratio and fraction problems';
      case Genre.reversePercentages:
        return 'Reverse percentage problems';
      case Genre.growthRate:
        return 'Growth rate calculations';
      case Genre.compounding:
        return 'Compounding problems';
      case Genre.breakeven:
        return 'Breakeven analysis';
      case Genre.weightedAverage:
        return 'Weighted average calculations';
      case Genre.scalingAndConversion:
        return 'Scaling and conversion problems';
    }
  }
}