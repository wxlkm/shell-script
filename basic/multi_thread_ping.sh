#!/bin/bash
#使用管道做多线程控制

rm -rf /tmp/fifotmp
mkfifo /tmp/fifotmp
exec 6<>/tmp/fifotmp

for i in {1..10}
do
        echo 'k'>&6
done

for i in {1..254}
do
        read -u 6
        {
        ip="192.168.0.$i"
        ping -c1 -W1 $ip &>/dev/null
        if [ $? -eq 0 ]; then
                echo 'k' >&6
                echo "$ip is ok"
        else
                echo 'k' >&6
                echo "$ip is down"
        fi

        }&
done
wait
exec 8>&-
echo "all done"
