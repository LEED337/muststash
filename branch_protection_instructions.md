# Checking Branch Protection Rules in GitHub

## Step 1: Go to Repository Settings
1. Navigate to your GitHub repository: https://github.com/LEED337/muststash
2. Click on the "Settings" tab at the top of the repository page

## Step 2: Access Branch Protection Rules
1. In the left sidebar, click on "Branches"
2. Look for a section called "Branch protection rules"

## Step 3: Check Existing Rules
1. If there are any branch protection rules listed, click on them to view their details
2. Pay special attention to rules that might affect the `gh-pages` branch

## Step 4: What to Look For
Branch protection rules that could block deployment include:
- Required status checks that must pass before merging
- Required pull request reviews
- Restrictions on who can push to the branch
- Restrictions on force pushes (which GitHub Actions might need for deployment)

## Step 5: Modify Rules if Needed
If you find rules blocking the `gh-pages` branch:
1. Click "Edit" on the rule
2. Either exclude the `gh-pages` branch or modify the rule to allow GitHub Actions to push to it
3. Make sure to click "Save changes" when done

## Step 6: Check GitHub Actions Permissions
1. In the repository settings, click on "Actions" in the left sidebar
2. Under "General", find "Workflow permissions"
3. Ensure "Read and write permissions" is selected
4. Make sure "Allow GitHub Actions to create and approve pull requests" is checked
5. Click "Save" if you made any changes

These steps will help you identify and fix any branch protection issues that might be preventing your GitHub Pages deployment.