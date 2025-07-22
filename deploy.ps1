# AdNabbit Deployment Script
Write-Host "🚀 Deploying AdNabbit with OptiSigns Integration..." -ForegroundColor Green

# Build the web app
Write-Host "📦 Building Flutter web app..." -ForegroundColor Yellow
flutter build web --release --web-renderer html

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful!" -ForegroundColor Green
    
    # Add and commit changes
    Write-Host "📝 Committing changes..." -ForegroundColor Yellow
    git add .
    git commit -m "Deploy OptiSigns-integrated AdNabbit platform - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    
    # Push to GitHub
    Write-Host "🚀 Pushing to GitHub..." -ForegroundColor Yellow
    git push origin main
    
    Write-Host "🎉 Deployment initiated!" -ForegroundColor Green
    Write-Host "Your app will be live at: https://YOUR_USERNAME.github.io/adnabbit/" -ForegroundColor Cyan
    Write-Host "It may take 2-3 minutes to deploy." -ForegroundColor Yellow
} else {
    Write-Host "❌ Build failed. Please check the errors above." -ForegroundColor Red
}