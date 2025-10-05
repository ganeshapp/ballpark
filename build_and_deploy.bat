@echo off
REM BallPark Flutter Web Build and Deploy Script for Windows
REM This script builds the Flutter web app locally and prepares it for GitHub Pages

echo 🚀 Starting BallPark Flutter Web Build and Deploy...

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter is not installed or not in PATH
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo [INFO] Flutter found, checking version...
flutter --version

REM Check if we're in the right directory
if not exist "pubspec.yaml" (
    echo [ERROR] pubspec.yaml not found. Please run this script from the Flutter project root.
    pause
    exit /b 1
)

REM Clean previous builds
echo [INFO] Cleaning previous builds...
flutter clean

REM Get dependencies
echo [INFO] Getting Flutter dependencies...
flutter pub get

REM Check for any issues
echo [INFO] Checking for Flutter issues...
flutter doctor

REM Build for web
echo [INFO] Building Flutter web app...
flutter build web --release

REM Check if build was successful
if not exist "build\web" (
    echo [ERROR] Build failed - build\web directory not found
    pause
    exit /b 1
)

echo [SUCCESS] Flutter web build completed successfully!

REM Create docs directory for GitHub Pages
echo [INFO] Preparing for GitHub Pages deployment...
if exist "docs" (
    echo [INFO] Removing existing docs directory...
    rmdir /s /q docs
)

REM Copy build output to docs directory
echo [INFO] Copying build output to docs directory...
xcopy /e /i build\web docs

REM Add a .nojekyll file to prevent Jekyll processing
echo. > docs\.nojekyll

echo [SUCCESS] GitHub Pages files prepared in docs\ directory

echo.
echo [SUCCESS] 🎉 Build completed successfully!
echo.
echo [INFO] Next steps to deploy to GitHub Pages:
echo 1. Commit and push the docs\ directory to your repository:
echo    git add docs/
echo    git commit -m "Deploy Flutter web app to GitHub Pages"
echo    git push origin main
echo.
echo 2. Enable GitHub Pages in your repository settings:
echo    - Go to Settings ^> Pages
echo    - Source: Deploy from a branch
echo    - Branch: main / docs
echo    - Save
echo.
echo [INFO] Your app will be available at: https://[your-username].github.io/ballpark
echo.

echo [INFO] Build information:
echo   - Build directory: build\web
echo   - Deploy directory: docs\
echo   - Build type: Release (optimized)
echo   - Web renderer: HTML
echo.

echo [SUCCESS] Ready for deployment! 🚀
pause
