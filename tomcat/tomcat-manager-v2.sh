#!/bin/bash
#
# chkconfig: - 95 15
# description: Tomcat start/stop/status script
# 2020/4/8 modify
# 1, in function tomcat_pid()，while this script is executed by bash like in Jenkins, could not get the rihgt pid  
# so add $0 in grep -v section.
# ########################## # 

#Location of JAVA_HOME (bin files)
JAVA_HOME=
[ ${#JAVA_HOME} -ne 0 ] && export JAVA_HOME

#Add Java binary files to PATH
[ ${#JAVA_HOME} -ne 0 ] && PATH=$JAVA_HOME/bin:$PATH

export PATH

#CATALINA_HOME is the location of the configuration files of this instance of Tomcat
CATALINA_HOME="/soft/server/apache-tomcat-8.5.53"

#TOMCAT_USER is the default user of tomcat
TOMCAT_USER=appuser

#TOMCAT_USAGE is the message if this script is called without any options
TOMCAT_USAGE="Usage: $0 {\e[00;32mstart\e[00m|\e[00;31mstop\e[00m|\e[00;32mstatus\e[00m|\e[00;31mrestart\e[00m}"

#SHUTDOWN_WAIT is wait time in seconds for java proccess to stop
SHUTDOWN_WAIT=20

tomcat_pid() {
        echo `ps aux | grep $CATALINA_HOME | egrep -v "grep|$0" | tr -s " "|cut -d" " -f2`
        #ps aux | grep $CATALINA_HOME | egrep -v "grep|$0"
}

start() {
  pid=$(tomcat_pid)
  if [ -n "$pid" ];then
    echo -e "\e[00;31mTomcat is already running (pid: $pid)\e[00m"
  else
    echo -e "\e[00;32mStarting tomcat\e[00m"
    if [ `user_exists $TOMCAT_USER` = "1" ];then
      su $TOMCAT_USER -c $CATALINA_HOME/bin/startup.sh
    else
      $CATALINA_HOME/bin/startup.sh
    fi
    status
  fi
  return 0
}

status(){
  pid=$(tomcat_pid)
  if [ -n "$pid" ];then
    echo -e "\e[00;32mTomcat is running with pid: $pid\e[00m"
  else
    echo -e "\e[00;31mTomcat is not running\e[00m"
  fi
}

stop() {
  pid=$(tomcat_pid)
  if [ -n "$pid" ];then
    echo -e "\e[00;31mStoping Tomcat\e[00m"
        $CATALINA_HOME/bin/shutdown.sh

    let kwait=$SHUTDOWN_WAIT
    count=0;
    until [ `ps -p $pid | grep -c $pid` = '0' ] || [ $count -gt $kwait ]
    do
      echo -n -e "\e[00;31mwaiting for processes to exit\e[00m\n";
      sleep 1
      let count=$count+1;
    done

    if [ $count -gt $kwait ];then
      echo -n -e "\n\e[00;31mkilling processes which didn't stop after $SHUTDOWN_WAIT seconds\e[00m"
      kill -9 $pid
    fi
    status
  else
    echo -e "\e[00;31mTomcat is not running\e[00m"
  fi

  return 0
}

user_exists(){
  if id -u $1 >/dev/null 2>&1; then
    echo "1"
  else
    echo "0"
  fi
}

case $1 in
        start)
          start
        ;;

        stop)
          stop
        ;;

        restart)
          stop
          start
        ;;

        status)
      	  status
        ;;
	      getpid)
	        tomcat_pid
	      ;;
        *)
      	  echo -e $TOMCAT_USAGE
        ;;
esac
exit 0

