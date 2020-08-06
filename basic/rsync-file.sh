#!/bin/bash

flyData(){
rsync -avz --delete /lyzdData/var/ftp/pub/flyData/ root@114.116.223.6:/opt/sftp/lyzdsftp/flyData/
}

ljtData(){
rsync -avz --delete /lyzdData/var/ftp/pub/ljtData/ root@114.116.223.6:/opt/sftp/lyzdsftp/ljtData/
}

zgData(){
rsync -avz --delete /lyzdData/var/ftp/pub/zgData/ root@114.116.223.6:/opt/sftp/lyzdsftp/zgData/
}

case $1 in
  $1) $1
  ;;
esac

将脚本定时执行：
[root@i-dspdaxomd14i-1 script]# crontab -l
*/2 * * * * . /etc/profile;python /etc/safedog/sdcc/script/sdmonitor_check.py -c
2 1 * * * /root/script/rsync-sftp.sh flyData >> /root/script/rsync-flyData.log
30 1 * * * /root/script/rsync-sftp.sh ljtData >> /root/script/rsync-ljtData.log
30 2 * * * /root/script/rsync-sftp.sh zgData >> /root/script/rsync-zgData.log
