# $Datapath = Get-Location

$Datas = Import-Csv -Path "./mvts.csv" -Encoding UTF8
#データファイルの行数分ループ


for ($i = 0; $i -lt $Datas.Length; $i++) {

  $x = $Datas[$i].x
  $y = $Datas[$i].y
  $z = $Datas[$i].z

  $dirc = "./mvts/$i"
  if (!(Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
  }

  # Write-Host "$Datapath/mvts/$z/$x/$y/mvt.pbf"

  $hex = $Datas[$i].encode -replace '^\\x','' -replace '[^0-9a-f]',''
  if ($hex.Length % 2 -ne 0) { throw "16進データの桁数が偶数ではありません" }
  $byteArray = for ($j=0; $j -lt $hex.Length; $j+=2) { [Convert]::ToByte($hex.Substring($j,2),16) }
  [System.IO.File]::WriteAllBytes("$dirc/mvt.pbf", $byteArray)

}
