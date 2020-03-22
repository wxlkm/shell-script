#!/bin/bash
# show count of tcp connection state
# author wxlkm

declare -A count

types=($(netstat -ant | awk 'NR>2 {print $NF}'))

echo ${types[@]}
for item in ${types[@]}
do
        let count[$item]++
done

for item in ${!count[@]}
do
        echo "${item}: ${count[$item]}"
done
