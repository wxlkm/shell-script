#!/bin/bash
# count the number of each shell type
# author: wxlkm
# 脚本中获取typeshell两种方式
# 字符串变量的匹配删除操作:${var#}, ${var##}, ${var%}, ${var%%}
# 实现本脚本的功能：awk
# awk -F'/' '{print $NF}' /etc/passwd | sort | uniq -c

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
