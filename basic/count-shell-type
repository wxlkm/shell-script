#!/bin/bash
# count the number of each shell type
# author: wxlkm

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
