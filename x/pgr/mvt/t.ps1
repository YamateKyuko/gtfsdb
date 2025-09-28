# npx wrangler kv bulk put "$PSScriptRoot/data.json" --binding=mvts --remote


Invoke-Expression (Get-Content "$PSScriptRoot/env.ps1" -Raw)

Write-Host $global:pguser