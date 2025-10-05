#!/bin/bash

# BallPark Flutter Web Build and Deploy Script
# This script builds the Flutter web app locally and deploys it to GitHub Pages

set -e  # Exit on any error

echo "🚀 Starting BallPark Flutter Web Build and Deploy..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed and accessible
print_status "Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    print_status "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1)
print_success "Found Flutter: $FLUTTER_VERSION"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Please run this script from the Flutter project root."
    exit 1
fi

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get

# Check for any issues
print_status "Checking for Flutter issues..."
flutter doctor

# Build for web
print_status "Building Flutter web app..."
flutter build web --release

# Check if build was successful
if [ ! -d "build/web" ]; then
    print_error "Build failed - build/web directory not found"
    exit 1
fi

print_success "Flutter web build completed successfully!"

# Create docs directory for GitHub Pages
print_status "Preparing for GitHub Pages deployment..."
if [ -d "docs" ]; then
    print_status "Removing existing docs directory..."
    rm -rf docs
fi

# Copy build output to docs directory
print_status "Copying build output to docs directory..."
cp -r build/web docs

# Create a simple index.html redirect if needed
print_status "Creating GitHub Pages configuration..."

# Add a .nojekyll file to prevent Jekyll processing
touch docs/.nojekyll

# Create a simple README for the docs directory
cat > docs/README.md << EOF
# BallPark - Mental Math Trainer

This is the deployed web version of BallPark, a mental math training application built with Flutter.

## Features

- 12 different problem types (Addition, Subtraction, Multiplication, etc.)
- Customizable precision and time limits
- Real-time performance tracking
- Detailed analytics and charts
- Keyboard and touch support

## Usage

Simply open index.html in your browser or visit the GitHub Pages URL.

Built with Flutter Web.
EOF

print_success "GitHub Pages files prepared in docs/ directory"

# Show next steps
echo ""
print_success "🎉 Build completed successfully!"
echo ""
print_status "Next steps to deploy to GitHub Pages:"
echo "1. Commit and push the docs/ directory to your repository:"
echo "   git add docs/"
echo "   git commit -m 'Deploy Flutter web app to GitHub Pages'"
echo "   git push origin main"
echo ""
echo "2. Enable GitHub Pages in your repository settings:"
echo "   - Go to Settings > Pages"
echo "   - Source: Deploy from a branch"
echo "   - Branch: main / docs"
echo "   - Save"
echo ""
print_status "Your app will be available at: https://[your-username].github.io/ballpark"
echo ""

# Show build info
print_status "Build information:"
echo "  - Build directory: build/web"
echo "  - Deploy directory: docs/"
echo "  - Build type: Release (optimized)"
echo "  - Web renderer: HTML"
echo ""

print_success "Ready for deployment! 🚀"
