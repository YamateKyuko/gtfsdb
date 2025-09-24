# $Datapath = Get-Location

$Datas = Import-Csv -Path "./t.csv" -Encoding UTF8
#データファイルの行数分ループ

for ($i = 0; $i -lt $Datas.Length; $i++) {

    $byteArray = -split $Datas[$i].d -replace '(.{2})', '$1 ' 
$Data.d

[System.IO.File]::WriteAllBytes("./$i.txt", [byte[]]($byteArray -as [byte[]]))

}
