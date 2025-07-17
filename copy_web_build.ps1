$buildWebPath = "build\web\*"
$rootPath = "."

# Remove all files except .git and build folder
Get-ChildItem -Path $rootPath -Exclude @(".git", "build", "copy_web_build.ps1") | Remove-Item -Recurse -Force

# Copy web build files to root
Copy-Item -Path $buildWebPath -Destination $rootPath -Recurse -Force

Write-Host "Web build files copied to root directory for GitHub Pages deployment"