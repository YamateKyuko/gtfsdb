Invoke-Expression (Get-Content "$PSScriptRoot/env.ps1" -Raw)

# Write-Host $global:kvid



# npx wrangler kv bulk put "$PSScriptRoot/data.json" `
# --binding="mvts" `
# --remote


npx wrangler kv key list --binding="mvts" --remote > "$PSScriptRoot/keys.json"

# $keysjson = Get-Content -Raw "$PSScriptRoot/keys.json" | ConvertFrom-Json 
# $delkeys = @()
# foreach ($keyrow in $keysjson) {
#   $jsonobj = @{key = $keyrow.name}
#   $delkeys += $jsonobj
# }

# ConvertTo-Json $delkeys > "$PSScriptRoot/delkeys.json"
# # Write-Host $str

Write-Host | npx wrangler kv bulk delete "$PSScriptRoot/keys.json" --binding="mvts" 