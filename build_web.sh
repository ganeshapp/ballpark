#!/bin/bash

# Build script for Flutter web app
echo "🏟️ Building Ballpark Flutter Web App..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter from: https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build for web
echo "🌐 Building web app..."
flutter build web --release --base-href "/ballpark/"

# Copy to docs folder for GitHub Pages
echo "📁 Copying build to docs folder..."
rm -rf docs/*
cp -r build/web/* docs/

echo "✅ Build complete! Files are ready in the docs/ folder"
echo "🚀 You can now commit and push to deploy to GitHub Pages"
