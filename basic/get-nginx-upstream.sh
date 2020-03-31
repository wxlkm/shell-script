#!/bin/bash

action='n'

while read line
do
        if [[ $line =~ upstream.*\{ ]];then
                action='y'
        elif [[ $line =~ .*\}$ ]];then
                action='n'
        elif [[ $line =~ ^$ ]];then
                continue
        else
                :
        fi

        if [ $action = 'y' ];then
                echo $line
        fi
done <nginx.conf
