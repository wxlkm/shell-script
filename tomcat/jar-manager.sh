#!/bin/bash
#################################################################
#
#Usage: sh jar-manager.sh [start|stop|restart|status|log|backup]
#
#################################################################

# the user who will run this app
APP_USER="appuser"

# the name of the jar
APP_NAME="mmt-point-rest-1.0.0-SNAPSHOT.jar"

# JVM options
#JVM_OPTS="-server -Xms2g -Xmx2g -Xmn512m -XX:PermSize=128M -XX:MaxNewSize=128m -XX:MaxPermSize=25zh6m -Xss256k  -Djava.awt.headless=true -XX:+CMSClassUnloadingEnabled -XX:+CMSPermGenSweepingEnabled -Xloggc:/logs/xxx-server/GC/xxx-gc.log"
JVM_OPTS="-server -Xmx2g -Xms2g -Xmn256m -XX:PermSize=128m -Xss256k -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:LargePageSizeInBytes=128m -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 -Denv=pro -Didc=default"

#APPFILE_PATH="-Dspring.config.location=/usr/local/config/application.properties"

# usage of this shell script
usage() {
    echo "Usage: sh jar-manager.sh [start|stop|restart|status|log|backup]"
    exit 1
}

#check the status of this app
is_exist(){
    pid=`ps -ef|grep $APP_NAME|grep -v grep|awk '{print $2}' `
    #if not running return 1, else return 0
    if [ -z "${pid}" ]; then
        return 1
    else
        return 0
    fi
}

#start the app
start(){
    is_exist
    if [ $? -eq "0" ]; then
        echo "${APP_NAME} is already running. pid=${pid}."
    else
        #nohup java $JVM_OPTS -jar $APPFILE_PATH $APP_NAME > /dev/null 2>&1
        #nohup java $JVM_OPTS -jar $APP_NAME --spring.profiles.active=prod > /dev/null 2>&1 &
        su ${APP_USER} -c "nohup java $JAVA_MEM_OPTS -jar $APP_NAME >> nohup.out 2>&1 &"
        is_exist
        if [ $? -eq "0" ]; then
            echo "${APP_NAME} is running now. pid=${pid}."
        fi
    fi
}

#stop the app
stop(){
    is_exist
    if [ $? -eq "0" ]; then
        kill -9 $pid
    if [ $? -eq 0  ];then
        echo "${APP_NAME} is stopped."
        fi
    else
        echo "${APP_NAME} is not running."
    fi
}

#show the status of this app
status(){
    is_exist
    if [ $? -eq "0" ]; then
        echo "${APP_NAME} is running. Pid is ${pid}."
    else
        echo "${APP_NAME} is NOT running."
    fi
}
#restart the app
restart(){
    stop
    sleep 2
    start
}

#tail the app log
log(){
    tail -n 100 -f nohup.out
}

#backup the app
backup(){
    BACKUP_PATH=backup
    BACKUP_DATE=`date +"%Y%m%d-%H%M"`
    echo "backup file -> $BACKUP_PATH/${BACKUP_DATE}-${APP_NAME}"
    cp -r $APP_NAME  $BACKUP_PATH/${BACKUP_DATE}-${APP_NAME}
}


case "$1" in
    "start")
        start
        ;;
    "stop")
        stop
        ;;
    "status")
        status
        ;;
    "restart")
        restart
        ;;
    "log")
        log
        ;;
    "backup")
        backup
        ;;
    *)
        usage
        ;;
esac
