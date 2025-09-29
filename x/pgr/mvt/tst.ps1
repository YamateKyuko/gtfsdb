# $Datapath = Get-Location

Invoke-Expression (Get-Content "$PSScriptRoot/env.ps1" -Raw)

Write-Host $global:pguser

psql gtfsdb -c "select z, x, y, encode(data, 'hex') from map.mvts;" --csv -U $global:pguser -p 5432 -q -o './mvts.csv'

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
$str = ConvertTo-Json $json
# Write-Host $str
$str | Out-File -FilePath "$PSScriptRoot/data.json" -Encoding UTF8
