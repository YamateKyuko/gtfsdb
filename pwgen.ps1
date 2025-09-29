param(
    [int]$length = 12,
    [int]$count = 1,
    [switch]$A,      # 大文字なし
    [switch]$n,      # 最低でも一つの数字
    [switch]$Zero,   # 数字なし
    [switch]$y,      # 最低でも一つの記号
    [string]$r,      # 除外する記号リスト
    [switch]$s,      # 完全ランダム
    [switch]$B,      # 紛らわしい文字なし
    [switch]$C,      # 一行内に複数の結果
    [switch]$One     # 一つごとに改行
)

# 紛らわしい文字
$ambiguous = "Il1O0"

# 文字セット
$lower = "abcdefghijklmnopqrstuvwxyz"
$upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
$digits = "0123456789"
$symbols = "!@#$%^&*()-_=+[]{};:,.<>/?"

# 記号除外
if ($r) {
    $symbols = ($symbols.ToCharArray() | Where-Object { $r -notcontains $_ }) -join ''
}

# 紛らわしい文字除外
if ($B) {
    $lower = ($lower.ToCharArray() | Where-Object { $ambiguous -notcontains $_ }) -join ''
    $upper = ($upper.ToCharArray() | Where-Object { $ambiguous -notcontains $_ }) -join ''
    $digits = ($digits.ToCharArray() | Where-Object { $ambiguous -notcontains $_ }) -join ''
}

# 文字セット構築
$charset = $lower
if (-not $A) { $charset += $upper }
if (-not $Zero) { $charset += $digits }
if ($y) { $charset += $symbols }

function Get-RandomChar($set) {
    return $set | Get-Random
}

function New-Password {
    param($len)
    $pw = ""
    if ($s) {
        # 完全ランダム
        for ($i=0; $i -lt $len; $i++) {
            $pw += Get-RandomChar ($charset.ToCharArray())
        }
    } else {
        # 条件付き
        $pw += Get-RandomChar ($lower.ToCharArray())
        if (-not $A) { $pw += Get-RandomChar ($upper.ToCharArray()) }
        if (-not $Zero) { $pw += Get-RandomChar ($digits.ToCharArray()) }
        if ($y) { $pw += Get-RandomChar ($symbols.ToCharArray()) }
        for ($i=$pw.Length; $i -lt $len; $i++) {
            $pw += Get-RandomChar ($charset.ToCharArray())
        }
        $pw = ($pw.ToCharArray() | Sort-Object {Get-Random}) -join ''
    }
    return $pw.Substring(0, $len)
}

# 出力
$result = @()
for ($i=0; $i -lt $count; $i++) {
    $result += New-Password $length
}

if ($C) {
    Write-Output ($result -join ' ')
} elseif ($One) {
    $result | Write-Output
} else {
    Write-Output ($result -join "`n")
}

# -help
# ヘルプ
# c
# 最低でも一つの大文字
# -A
# 大文字なし
# -n
# 最低でも一つの数字
# -0
# 数字なし
# -y
# 最低でも一つの記号
# -r <chars>
# リストの記号を除く
# -s
# 完全ランダムで生成
# -B
# 紛らわしい文字なし
# -C
# 一行内に複数の結果
# -1
# 一つごとに改行