#!/bin/bash
#########################################################
# Function :Rotate nginx error logs and clean           #
#           block ip's configure file                   #
# Platform :All Linux Based Platform                    #
# Version  :1.0                                         #
# Date     :2017-07-28                                  #
# Author   :WuXinli                                     #
# Contact  :                                            #
# Company  :HZCF                                        #
#########################################################

BASE_DIR="/usr/local/nginx"
NGX_PID="$BASE_DIR/logs/nginx.pid"
NGINX_CMD="$BASE_DIR/sbin/nginx"
LOGS_DIR="$BASE_DIR/logs"
LOG_NAME="access.log"
BLOCK_IP_FILE="$BASE_DIR/conf/test/blockip.conf"

cd $LOGS_DIR && \
#/usr/bin/rename $LOG_NAME $(/usr/bin/date +%F-%H -d "last hour").$LOG_NAME $LOG_NAME && \
/usr/bin/rename $LOG_NAME $(/usr/bin/date +%F-%H-%M).$LOG_NAME $LOG_NAME && \
/usr/bin/kill -USR1 $(cat $NGX_PID)
>$BLOCK_IP_FILE && \
$($NGINX_CMD -s reload)
