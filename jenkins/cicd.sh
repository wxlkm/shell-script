#!/bin/bash

source /etc/profile

CURDIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
cd $CURDIR

jarName="mixmedia-site"
javaCommand="java -XX:+UseG1GC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintHeapAtGC -Xms4g -Xmx4g -jar -Dloader.path=libes6 ${jarName}.jar"

#检查程序是否在运行
is_exist(){ 
	pid=`ps -ef | grep ${jarName}.jar | grep -v grep | awk '{print $2}'` #如果不存在返回1，存在返回0
	if [ -z "${pid}" ]; then 
		return 1 #not exist
	else 
		return 0 #exist
	fi
} 
#启动方法 
start(){ 
	echo "### start:"$(date +'%Y-%m-%d %H:%M:%S')" ###"| tee -a logs/cicd.log
	is_exist 
	if [ $? -eq "0" ]; then 
		echo "${jarName}.jar is already running. pid=${pid}" | tee -a logs/cicd.log
	else 
		echo "nohup java ${jarName}.jar" | tee -a logs/cicd.log
		#echo nohup ${javaCommand} > /dev/null 2>&1 &
		nohup ${javaCommand} >/dev/null &
		echo $! > service.pid
		status
	fi 
}
#停止方法 
stop(){ 
	echo "### stop:"$(date +'%Y-%m-%d %H:%M:%S')" ###"| tee -a logs/cicd.log
	is_exist
	if [ $? -eq "0" ];then 
                echo "kill -9 $pid" | tee -a logs/cicd.log
		ps aux | grep ${jarName}.jar | grep -v grep | awk '{print $2}' | xargs kill -s 9
	else
		echo "${jarName}.jar is not running" 
	fi 
} 
#输出运行状态
status(){ 
	is_exist 
	if [ $? -eq "0" ]; then
		echo "${jarName}.jar is running. Pid is ${pid}" 
	else
		echo "${jarName}.jar is not running."
	fi 
} 
 #重启 
restart(){ 
	stop 
	start 
} 

backup(){
	time=`date +%Y%m%d%H%M%S`
	
	if [ ! -d packages ]; then
	    mkdir packages
	fi
	
	cp ${jarName}.jar packages/${jarName}.jar-${time}
	
	maxNum=6
	jarCount=`ls packages/ | grep ${jarName}.jar- | wc -l`
	echo $jarCount
	while [ ${jarCount} -gt ${maxNum} ]
	do
	    removeJar=`ls -ltr packages/ | grep ${jarName}.jar- | head -n 1 | awk '{print $9}'`
	    echo removeJar: $removeJar
	    rm packages/$removeJar
	    jarCount=`ls packages/ | grep ${jarName}.jar- | wc -l`
	done
}

rollback(){
	time=`date +%Y%m%d%H%M%S`

	rollbackJar=`ls -lt packages/ | grep ${jarName}.jar- | head -n 1 |awk '{print $9}'`
	echo "rollback jar is ${rollbackJar}."
	mv packages/${rollbackJar} ${jarName}.jar
}

showhelp(){
	echo "支持参数: start, stop, status, backup, rollback"
}


#根据输入参数，选择执行对应方法，不输入则执行使用说明 
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
	"backup")
		backup
		;;
	"rollback")
		rollback
		;;
	*)
		echo "参数错误！"
		showhelp
		exit 1
esac
