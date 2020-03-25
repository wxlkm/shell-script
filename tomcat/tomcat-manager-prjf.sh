#!/bin/bash
source /etc/profile
export apppath="$(cd `dirname $0`; pwd)"
export PATH=$PATH:$HOME/bin
export USERNAME="appuser"


case "$1" in
       start)
              #startup the tomcat
              #echo -n "tomcat start: "
              su -c "$apppath/bin/startup.sh" $USERNAME
              #. myconfig.sh
              #bash -lc ./startup.sh
              #echo "finished"
              ;;
       stop)
              # stop tomcat
              #echo -n "tomcat stop:"
              ps -ef | grep "$apppath" | grep "apache-tomcat-8.5.53" | grep -v grep | sed 's/ [ ]*/:/g'|cut -d: -f2| kill -9 `cat`
              #echo "finished"
              ;;
       reload|restart)
              $0 stop
              sleep 5
              $0 start
              ;;
       *)
              echo "Usage: tomcat [start|stop|reload|restart]"
              exit 1
esac
exit 0
