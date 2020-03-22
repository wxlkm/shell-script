#!/bin/bash
# count the number of each shell type
# author: wxlkm
# 脚本中获取typeshell两种方式
# 字符串变量的匹配删除操作:${var#}, ${var##}, ${var%}, ${var%%}

unset sum
declare -A sum
while read line
do
#       typeshell=${line##*/}
        typeshell=$(echo $line | awk -F'/' '{print $NF}')
        let sum[${typeshell}]++
done < /etc/passwd

for item in ${!sum[@]}
do
        echo "${item}: ${sum[$item]}"
done
