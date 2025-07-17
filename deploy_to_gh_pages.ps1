# Save the current branch name
$currentBranch = git rev-parse --abbrev-ref HEAD

# Build the Flutter web app
Write-Host "Building Flutter web app..."
flutter build web --release --base-href "/muststash/"

# Switch to gh-pages branch
Write-Host "Switching to gh-pages branch..."
git checkout gh-pages

# Remove all files except .git
Write-Host "Cleaning gh-pages branch..."
Get-ChildItem -Path . -Exclude .git | Remove-Item -Recurse -Force

# Copy the web build files
Write-Host "Copying web build files..."
Copy-Item -Path build\web\* -Destination . -Recurse

# Add all files to git
Write-Host "Adding files to git..."
git add .

# Commit the changes
Write-Host "Committing changes..."
git commit -m "Update GitHub Pages site"

# Push to GitHub
Write-Host "Pushing to GitHub..."
git push origin gh-pages

# Switch back to the original branch
Write-Host "Switching back to $currentBranch branch..."
git checkout $currentBranch

Write-Host "Deployment complete! Your site should be live at https://leed337.github.io/muststash/"