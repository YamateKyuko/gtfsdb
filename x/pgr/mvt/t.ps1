Invoke-Expression (Get-Content "$PSScriptRoot/env.ps1" -Raw)

# Write-Host $global:kvid



# npx wrangler kv bulk put "$PSScriptRoot/data.json" `
# --binding="mvts" `
# --remote




# $keysjson = Get-Content -Raw "$PSScriptRoot/keys.json" | ConvertFrom-Json 
# $delkeys = @()
# foreach ($keyrow in $keysjson) {
#   $jsonobj = @{key = $keyrow.name}
#   $delkeys += $jsonobj
# }

# ConvertTo-Json $delkeys > "$PSScriptRoot/delkeys.json"
# # Write-Host $str

# npx wrangler kv key list --binding="mvts" --remote |Out-File "$PSScriptRoot/keys.json" -Encoding UTF8
# Write-Host | npx wrangler kv bulk delete "$PSScriptRoot/keys.json" --binding="mvts" --remote 



