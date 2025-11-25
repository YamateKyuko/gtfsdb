# 配列の定義
my_array=("apple" "banana" "cherry")

# 配列の要素数を取得
array_length=${#my_array[@]}

# 結果の表示
echo "配列の要素数: $array_length"

seq 1 ${array_length}