param(
  [string]$Message = "Update site"
)

$ErrorActionPreference = "Stop"

hugo
git add -A

$stagedChanges = git diff --cached --name-only
if (-not $stagedChanges) {
  Write-Host "No changes to commit."
  exit 0
}

git commit -m $Message
git push
