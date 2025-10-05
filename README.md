# BallPark - Mental Math Trainer

A professional Flutter web application for training mental math skills with consulting-style problems.

## Features

- **12 Problem Types**: Addition, Subtraction, Multiplication, Division, Percentages, Ratios & Fractions, Reverse Percentages, Growth Rate, Compounding, Breakeven, Weighted Average, and Scaling & Conversion
- **Customizable Settings**: Adjustable precision (5% or 10%) and time limits (3 or 5 minutes)
- **Real-time Performance Tracking**: Live scoring and timer
- **Detailed Analytics**: Performance charts and statistics with genre filtering
- **Cross-platform Support**: Works on desktop, mobile, and web with keyboard and touch input
- **Data Persistence**: Session history and performance tracking

## Live Demo

🚀 **[Try BallPark Live](https://your-username.github.io/ballpark)** (replace with your GitHub Pages URL)

## Quick Start

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Git

### Local Development
```bash
# Clone the repository
git clone https://github.com/your-username/ballpark.git
cd ballpark

# Get dependencies
flutter pub get

# Run the app
flutter run -d chrome
```

### Local Build and Deploy

Since GitHub Actions may have billing limitations, you can build and deploy locally:

#### Option 1: Use Build Scripts
```bash
# For macOS/Linux
./build_and_deploy.sh

# For Windows
build_and_deploy.bat
```

#### Option 2: Manual Build
```bash
# Build for web
flutter build web --release

# Prepare for GitHub Pages
rm -rf docs
cp -r build/web docs
touch docs/.nojekyll

# Deploy
git add docs/
git commit -m "Deploy Flutter web app"
git push origin main
```

### GitHub Pages Setup
1. Go to repository Settings > Pages
2. Source: "Deploy from a branch"
3. Branch: "main", Folder: "/docs"
4. Save

## Architecture

```
lib/
├── app/theme/           # Consistent theming system
├── features/
│   ├── home/           # Home screen with settings
│   ├── problem/        # Problem solving interface
│   ├── results/        # Session results display
│   └── stats/          # Performance analytics
├── models/             # Data models
└── services/           # Business logic services
```

## Technology Stack

- **Flutter Web**: Cross-platform web development
- **Riverpod**: State management
- **Google Fonts**: Professional typography
- **FL Chart**: Performance analytics
- **Shared Preferences**: Data persistence

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

For issues and questions, please open a GitHub issue or contact the maintainers.

---

Built with ❤️ using Flutter
