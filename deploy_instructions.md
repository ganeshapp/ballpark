# Local Build and Deploy Instructions

Since GitHub Actions is not available due to billing issues, here's how to build and deploy your Flutter web app locally:

## Prerequisites

1. **Fix Flutter Permissions** (if needed):
   ```bash
   # Create Flutter config directory with proper permissions
   sudo mkdir -p ~/.config/flutter
   sudo chown -R $(whoami) ~/.config/flutter
   chmod 755 ~/.config/flutter
   ```

2. **Verify Flutter Installation**:
   ```bash
   flutter --version
   flutter doctor
   ```

## Build and Deploy Process

### Option 1: Use the Build Script (Recommended)

1. **Run the build script**:
   ```bash
   ./build_and_deploy.sh
   ```

2. **Commit and push the docs directory**:
   ```bash
   git add docs/
   git commit -m "Deploy Flutter web app to GitHub Pages"
   git push origin main
   ```

### Option 2: Manual Build Process

1. **Clean and get dependencies**:
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Build for web**:
   ```bash
   flutter build web --release
   ```

3. **Prepare for GitHub Pages**:
   ```bash
   # Remove existing docs directory
   rm -rf docs
   
   # Copy build output to docs
   cp -r build/web docs
   
   # Add .nojekyll file
   touch docs/.nojekyll
   ```

4. **Commit and push**:
   ```bash
   git add docs/
   git commit -m "Deploy Flutter web app to GitHub Pages"
   git push origin main
   ```

## GitHub Pages Setup

1. **Go to your repository on GitHub**
2. **Navigate to Settings > Pages**
3. **Configure the source**:
   - Source: "Deploy from a branch"
   - Branch: "main" 
   - Folder: "/docs"
4. **Click Save**

## Access Your App

Your app will be available at:
```
https://[your-github-username].github.io/ballpark
```

## Troubleshooting

### Flutter Permission Issues
If you get permission errors:
```bash
# Fix Flutter config permissions
sudo chown -R $(whoami) ~/.config
chmod -R 755 ~/.config
```

### Build Issues
If the build fails:
```bash
# Check Flutter doctor
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

### GitHub Pages Not Updating
- Wait 5-10 minutes for GitHub Pages to rebuild
- Check the Actions tab for any deployment errors
- Ensure the docs/ folder is in the root of your repository

## File Structure After Build

```
ballpark/
├── docs/                 # GitHub Pages deployment files
│   ├── index.html       # Main app entry point
│   ├── main.dart.js     # Compiled Dart code
│   ├── flutter.js       # Flutter web runtime
│   ├── .nojekyll        # Prevents Jekyll processing
│   └── assets/          # App assets
├── build/web/           # Flutter build output
└── lib/                 # Source code
```

## Benefits of Local Build

- ✅ No dependency on GitHub Actions
- ✅ Full control over build process
- ✅ Faster deployment (no CI/CD delays)
- ✅ Can test locally before deploying
- ✅ No billing issues with GitHub

## Next Steps

1. Run the build script or manual process
2. Push the docs/ directory to GitHub
3. Configure GitHub Pages
4. Share your live app URL!

Your BallPark mental math trainer will be live on the web! 🚀
