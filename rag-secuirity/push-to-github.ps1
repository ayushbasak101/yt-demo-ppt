$ErrorActionPreference = 'Stop'

$repoUrl = 'https://github.com/ayushbasak101/yt-demo-ppt.git'
$projectDir = $PSScriptRoot

Write-Host "`nPushing RAG Security walkthrough to $repoUrl" -ForegroundColor Cyan

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git was not found. Install Git for Windows from https://git-scm.com/download/win, reopen PowerShell, and run this script again.'
}

if (-not (Test-Path -LiteralPath (Join-Path $projectDir 'index.html'))) {
    throw 'index.html is missing. Extract the complete ZIP package and run the script from its extracted folder.'
}

Push-Location $projectDir
try {
    if (-not (Test-Path -LiteralPath (Join-Path $projectDir '.git'))) {
        & git init
        if ($LASTEXITCODE -ne 0) { throw 'git init failed.' }
    }

    $currentRemote = (& git remote get-url origin 2>$null)
    if ($LASTEXITCODE -eq 0 -and $currentRemote) {
        $currentRemote = $currentRemote.Trim()
        if ($currentRemote -ne $repoUrl -and $currentRemote -ne 'git@github.com:ayushbasak101/yt-demo-ppt.git') {
            throw "This folder already points to another Git remote: $currentRemote`nTo avoid pushing to the wrong repository, the script has stopped."
        }
    } else {
        & git remote add origin $repoUrl
        if ($LASTEXITCODE -ne 0) { throw 'Could not add the GitHub remote.' }
    }

    & git branch -M main
    if ($LASTEXITCODE -ne 0) { throw 'Could not set the branch to main.' }

    $gitName = (& git config user.name 2>$null)
    if (-not $gitName) {
        $gitName = Read-Host 'Enter the name to use for this Git commit'
        if (-not $gitName.Trim()) { throw 'A Git commit name is required.' }
        & git config --local user.name $gitName
    }

    $gitEmail = (& git config user.email 2>$null)
    if (-not $gitEmail) {
        $gitEmail = Read-Host 'Enter the email to use for this Git commit (your GitHub noreply email is also fine)'
        if (-not $gitEmail.Trim()) { throw 'A Git commit email is required.' }
        & git config --local user.email $gitEmail
    }

    & git add -- index.html README.md
    if ($LASTEXITCODE -ne 0) { throw 'git add failed.' }

    & git diff --cached --quiet
    if ($LASTEXITCODE -eq 1) {
        & git commit -m 'Add RAG Security interactive walkthrough'
        if ($LASTEXITCODE -ne 0) { throw 'git commit failed.' }
    } elseif ($LASTEXITCODE -ne 0) {
        throw 'Could not inspect staged changes.'
    } else {
        Write-Host 'No new changes to commit; continuing with push.' -ForegroundColor Yellow
    }

    Write-Host "`nPushing to GitHub. Complete the browser or credential-manager sign-in if prompted..." -ForegroundColor Cyan
    & git push --set-upstream origin main
    if ($LASTEXITCODE -ne 0) {
        throw 'Push failed. Check that you are signed in to GitHub and that your account has write access to ayushbasak101/yt-demo-ppt, then run the script again.'
    }

    Write-Host "`nSuccess! Repository: https://github.com/ayushbasak101/yt-demo-ppt" -ForegroundColor Green
    Write-Host 'The walkthrough is in the repository root as index.html.' -ForegroundColor Green
} finally {
    Pop-Location
}
