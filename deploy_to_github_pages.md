# 🚀 Deploy AdNabbit to GitHub Pages

## Quick Setup (5 minutes):

### 1. Create GitHub Repository
```bash
# Initialize git (if not already done)
git init
git add .
git commit -m "Complete OptiSigns-integrated AdNabbit platform"

# Create repository on GitHub.com and then:
git remote add origin https://github.com/YOUR_USERNAME/adnabbit.git
git branch -M main
git push -u origin main
```

### 2. Enable GitHub Pages
1. Go to your repository on GitHub.com
2. Click **Settings** tab
3. Scroll to **Pages** section
4. Under **Source**, select **GitHub Actions**

### 3. Create GitHub Actions Workflow
Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Build web
      run: flutter build web --release --web-renderer html
      
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      if: github.ref == 'refs/heads/main'
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./build/web
```

### 4. Push and Deploy
```bash
git add .
git commit -m "Add GitHub Pages deployment"
git push
```

**Your app will be live at:** `https://YOUR_USERNAME.github.io/adnabbit/`

---

## 🌐 Alternative Options:

### Option 2: Netlify (Drag & Drop)
1. Go to [netlify.com](https://netlify.com)
2. Drag the `build/web` folder to Netlify
3. Get instant live URL

### Option 3: Vercel (GitHub Integration)
1. Go to [vercel.com](https://vercel.com)
2. Connect your GitHub repository
3. Auto-deploys on every push

### Option 4: Firebase Hosting
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
firebase deploy
```

---

## 📱 Share with Friends:

Once deployed, share the URL:
- **GitHub Pages**: `https://YOUR_USERNAME.github.io/adnabbit/`
- **Netlify**: `https://random-name-123.netlify.app/`
- **Vercel**: `https://adnabbit-username.vercel.app/`

Your friends can access the full OptiSigns-integrated AdNabbit platform from any device! 🎉