# Flutter Web Release Build and Firebase Hosting Deploy
# Run from project root: .\build_and_deploy_web.ps1
#
# If this script won't run (execution policy):
#   Option A: Run the batch file instead:  build_and_deploy_web.bat
#   Option B: In PowerShell:  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
#   Option C:  powershell -ExecutionPolicy Bypass -File .\build_and_deploy_web.ps1
#
# Before first deploy:
#   1. Install Firebase CLI:  npm install -g firebase-tools
#   2. Log in:  firebase login
#   3. Ensure Flutter is in PATH and you're in the project root (where firebase.json is)

Write-Host "=== 1. Building Flutter web (release) ===" -ForegroundColor Cyan
flutter build web --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed. Exiting." -ForegroundColor Red
    exit 1
}

Write-Host "`n=== 2. Deploying to Firebase Hosting ===" -ForegroundColor Cyan
firebase deploy --only hosting
if ($LASTEXITCODE -ne 0) {
    Write-Host "Deploy failed. Exiting." -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Done ===" -ForegroundColor Green
Write-Host "Your app should be live at: https://getyourinvoice-8f128.web.app" -ForegroundColor Green
