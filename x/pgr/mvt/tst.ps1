psql gtfsdb `
-U $pguser `
-p 5432 `
-f "$PSScriptRoot/mvt.sql"

# $Datapath = Get-Location

Invoke-Expression (Get-Content "$PSScriptRoot/env.ps1" -Raw)

# Write-Host $global:pguser

psql gtfsdb `
-c "select z, x, y, encode(data, 'hex') from map.mvts;" `
--csv -q `
-U $global:pguser `
-p 5432 `
-o './mvts.csv'


$json = @()

# Write-Host "Datapath: $Datapath"
# Write-Host $PSScriptRoot
$Datas = Import-Csv -Path "$PSScriptRoot/mvts.csv" -Encoding UTF8
# #データファイルの行数分ループ

$dirc = "$PSScriptRoot/mvts"
Remove-Item -Path $dirc -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue
if (!(Test-Path $dirc)) {
  New-Item -ItemType Directory -Path $dirc | Out-Null
}

for ($i = 0; $i -lt $Datas.Length; $i++) {

  $x = $Datas[$i].x
  $y = $Datas[$i].y
  $z = $Datas[$i].z

  # $dirc = "$PSScriptRoot/mvts/$z-$x-$y"
  # if (!(Test-Path $dirc)) {
  #   New-Item -ItemType Directory -Path $dirc | Out-Null
  # }


  $hex = $Datas[$i].encode -replace '^\\x','' -replace '[^0-9a-f]',''
  if ($hex.Length % 2 -ne 0) { throw "16進データの桁数が偶数ではありません" }
  $byteArray = for ($j=0; $j -lt $hex.Length; $j+=2) { [Convert]::ToByte($hex.Substring($j,2),16) }
  [System.IO.File]::WriteAllBytes("$dirc/$z-$x-$y.pbf", $byteArray)


  $b64enc = [Convert]::ToBase64String($byteArray)

  $row = @{
    key = "$z/$x/$y"
    value = $b64enc
  }

  # $jsonOutput = ConvertTo-Json $row

  $json += $row
}

ConvertTo-Json $json | Out-File -FilePath "$PSScriptRoot/data.json" -Encoding UTF8

npx wrangler kv key list --binding="mvts" --remote |Out-File "$PSScriptRoot/keys.json" -Encoding UTF8

Write-Host | npx wrangler kv bulk delete "$PSScriptRoot/keys.json" --binding="mvts" --remote 

npx wrangler kv bulk put "$PSScriptRoot/data.json" --binding="mvts" --remote

Remove-Item -Path "$PSScriptRoot/keys.json" -Force
Remove-Item -Path "$PSScriptRoot/data.json" -Force
Remove-Item -Path "$PSScriptRoot/mvts.csv" -Force

Remove-Item -Path $dirc -Force -Recurse -Confirm:$false -ErrorAction SilentlyContinue