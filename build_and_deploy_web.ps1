# Flutter Web Release Build and Firebase Hosting Deploy
# Run from project root: .\build_and_deploy_web.ps1

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
