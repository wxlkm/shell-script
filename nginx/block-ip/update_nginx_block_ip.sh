#!/bin/bash
#########################################################
# Function :Get the ip needed to be blocked and update  #
#           the configure file of blocked ip.           #
# Platform :All Linux Based Platform                    #
# Version  :1.0                                         #
# Date     :2017-07-28                                  #
# Author   :WuXinli                                     #
# Contact  :                                            #
# Company  :HZCF                                        #
#########################################################
BASE_DIR="/usr/local/nginx"
LOGS_DIR="$BASE_DIR/logs"
LOG_NAME="access.log"
#included config file
BLOCK_IP_CONF="$BASE_DIR/conf/test/blockip.conf"
#already blocked ip
BLOCKED_IP="/dev/shm/blocked-ip.txt"
#new block ip
BLOCK_IP="/dev/shm/block-ip.txt"
NGX_PID="$BASE_DIR/logs/nginx.pid"
NGINX_CMD="$BASE_DIR/sbin/nginx"

/usr/bin/cp $BLOCK_IP_CONF $BLOCKED_IP && \
/usr/bin/sed -nr 's#(([0-9]+\.){3}[0-9]+).*#\1#p' $LOGS_DIR/$LOG_NAME | \
/usr/bin/awk '{IP[$1]++}END{for (i in IP) print IP[i],i}' | \
/usr/bin/awk '{if($1>10){print "deny "$2";"}}'>$BLOCK_IP && \
grep -v -f $BLOCK_IP_CONF $BLOCK_IP >>$BLOCK_IP_CONF && \
$($NGINX_CMD -s reload)
