#!/bin/bash
#show system information

PS3="Your choice is: "
os_check() {
        if [ -e /etc/redhat-release ]; then
                REDHAT=`cat /etc/redhat-release |cut -d' '  -f1`
        else
                DEBIAN=`cat /etc/issue |cut -d' ' -f1`
        fi

        if [ "$REDHAT" == "CentOS" -o "$REDHAT" == "Red" ]; then
                P_M=yum
        elif [ "$DEBIAN" == "Ubuntu" -o "$DEBIAN" == "ubutnu" ]; then
                P_M=apt-get
        else
                Operating system does not support.
                exit 1
        fi
}

#检查所用到的工具，如果不存在则安装
tool_check(){
    if ! which vmstat &>/dev/null; then
        echo "vmstat command not found, now the install."
        sleep 1
        os_check
        $P_M install procps -y
        echo "-----------------------------------------------------------------------"
    fi
    
    which iostat &>/dev/null
    if [ $? -ne 0 ]; then
            echo "iostat command not found, now the install."
            sleep 1
            os_check
            $P_M install sysstat -y
            echo "-----------------------------------------------------------------------"
    fi
}
#CPU利用率与负载
cpu_load() {
    echo "---------------------------------------"
    i=1
    while [[ $i -le 3 ]]; do
        echo -e "\033[32m  参考值${i}\033[0m"
        UTIL=`vmstat |awk '{if(NR==3)print 100-$15"%"}'`
        USER=`vmstat |awk '{if(NR==3)print $13"%"}'`
        SYS=`vmstat |awk '{if(NR==3)print $14"%"}'`
        IOWAIT=`vmstat |awk '{if(NR==3)print $16"%"}'`
        echo "Util: $UTIL"
        echo "User use: $USER"
        echo "System use: $SYS"
        echo "I/O wait: $IOWAIT"
        let i++
        sleep 1
    done
    echo "---------------------------------------"    
}

#占用CPU高的前10个进程
cpu_top10(){
    echo "---------------------------------------"
    CPU_LOG=/tmp/cpu_top.tmp
    i=1
    while [[ $i -le 3 ]]; do
        #ps aux |awk '{if($3>0.1)print "CPU: "$3"% -->",$11,$12,$13,$14,$15,$16,"(PID:"$2")" |"sort -k2 -nr |head -n 10"}' > $CPU_LOG
        ps aux |awk '{if($3>0.1){{printf "PID: "$2" CPU: "$3"% --> "}for(i=11;i<=NF;i++)if(i==NF)printf $i"\n";else printf $i}}' |sort -k4 -nr |head -10 > $CPU_LOG
        #循环从11列（进程名）开始打印，如果i等于最后一行，就打印i的列并换行，否则就打印i的列
        if [[ -n `cat $CPU_LOG` ]]; then
           echo -e "\033[32m  参考值${i}\033[0m"
           cat $CPU_LOG
           > $CPU_LOG
        else
            echo "No process using the CPU." 
            break
        fi
        let i++
        sleep 1
    done
    echo "---------------------------------------"
}

#内存利用率
mem_use(){
    echo "---------------------------------------"
    MEM_TOTAL=`free -m |awk '{if(NR==2)printf "%.1f",$2/1024}END{print "G"}'`
    USE=`free -m |awk '{if(NR==2) printf "%.1f",$3/1024}END{print "G"}'`
    FREE=`free -m |awk '{if(NR==2) printf "%.1f",$4/1024}END{print "G"}'`
    CACHE=`free -m |awk '{if(NR==2) printf "%.1f",$6/1024}END{print "G"}'`
    echo -e "Total: $MEM_TOTAL"
    echo -e "Use: $USE"
    echo -e "Free: $FREE"
    echo -e "Cache: $CACHE"
    echo "---------------------------------------"
}

#占用内存高的前10个进程
mem_top10(){
    echo "---------------------------------------"
    MEM_LOG=/tmp/mem_top.tmp
    i=1
    while [[ $i -le 3 ]]; do
        #ps aux |awk '{if($4>0.1)print "Memory: "$4"% -->",$11,$12,$13,$14,$15,$16,"(PID:"$2")" |"sort -k2 -nr |head -n 10"}' > $MEM_LOG
        ps aux |awk '{if($4>0.1){{printf "PID: "$2" Memory: "$4"% --> "}for(i=11;i<=NF;i++)if(i==NF)printf $i"\n";else printf $i}}' |sort -k4 -nr |head -10 > $MEM_LOG
        if [[ -n `cat $MEM_LOG` ]]; then
            echo -e "\033[32m  参考值${i}\033[0m"
            cat $MEM_LOG
            > $MEM_LOG
        else
            echo "No process using the Memory."
            break
        fi
        i=$(($i+1))
        sleep 1
    done
    echo "---------------------------------------"
}

#硬盘I/O负载
disk_load(){
    echo "---------------------------------------"
    i=1
    while [[ $i -le 3 ]]; do
        echo -e "\033[32m  参考值${i}\033[0m"
        UTIL=`iostat -x -k |awk '/^[v|s]/{OFS=": ";print $1,$NF"%"}'`
        READ=`iostat -x -k |awk '/^[v|s]/{OFS=": ";print $1,$6"KB"}'`
        WRITE=`iostat -x -k |awk '/^[v|s]/{OFS=": ";print $1,$7"KB"}'`
        IOWAIT=`vmstat |awk '{if(NR==3)print $16"%"}'`
        echo -e "Util:"
        echo -e "${UTIL}"
        echo -e "I/O Wait: $IOWAIT"
        echo -e "Read/s:\n$READ"
        echo -e "Write/s:\n$WRITE"
        i=$(($i+1))
        sleep 1
    done
    echo "---------------------------------------"
}

#硬盘利用率
disk_use(){
    DISK_LOG=/tmp/disk_use.tmp
    DISK_TOTAL=`fdisk -l |awk '/^Disk.*bytes/ && /\/dev/{printf $2" ";printf "%d",$3;print "GB"}'`
    USE_RATE=`df -h |awk '/^\/dev/{print int($5)}'`
    for i in $USE_RATE; do
        if [ $i -gt 90 ];then
            PART=`df -h |awk '{if(int($5)=='''$i''') print $6}'`
            echo "$PART = ${i}%" >> $DISK_LOG
        fi
    done

    echo "---------------------------------------"
    echo -e "Disk total:\n${DISK_TOTAL}"
    if [ -f $DISK_LOG ]; then
        echo "---------------------------------------"
        cat $DISK_LOG
        echo "---------------------------------------"
        rm -f $DISK_LOG
    else
        echo "---------------------------------------"
        echo "Disk use rate no than 90% of the partition."
        echo "---------------------------------------"
    fi
}

#硬盘inode利用率
disk_inode(){
    INODE_LOG=/tmp/inode_use.tmp
    INODE_USE=`df -i |awk '/^\/dev/{print int($5)}'`
    for i in $INODE_USE; do
        if [ $i -gt 90 ]; then
            PART=`df -i |awk '{if(int($5)=='''$i''') print $6}'`
            echo "$PART = ${i}%" >> $INODE_LOG
        fi
    done
    if [ -f $INODE_LOG ]; then
        echo "---------------------------------------"
    cat $INODE_LOG
        rm -f $INODE_LOG
    else
        echo "---------------------------------------"
        echo "Inode use rate no than 90% of the partition."
        echo "---------------------------------------"
    fi
}

#网络连接状态
tcp_status(){
    echo "---------------------------------------"
    COUNT=`ss -ant |awk '!/State/{status[$1]++}END{for(i in status) print i,status[i]}'`
    echo -e "TCP connection status:\n$COUNT"
    echo "---------------------------------------"
}

#查看网络流量
net_traffic(){
    while true; do
        read -p "Please enter the network card name(eth[0-9] or em[0-9] or team[0-9]): " eth
        if [ `ifconfig |grep -c "\<$eth\>"` -eq 1 ]; then
                break
        else
            echo "Input format error or Don\'t have the card name, please input again."
        fi
    done

    echo "---------------------------------------"
    
    echo -e " In ------ Out"
    i=1
    while [[ $i -le 3 ]]; do
        #CentOS6和CentOS7 ifconfig输出进出流量信息位置不同:
        #CentOS6中RX与TX行号等于8
        #CentOS7中RX行号是4，TX行号是6

        OLD_IN=`ifconfig $eth |awk -F'[: ]+' '/bytes/{if(NR==4)print $6;else if(NR==8)print $4}'`
        OLD_OUT=`ifconfig $eth |awk -F'[: ]+' '/bytes/{if(NR==6)print $6;else if(NR==8)print $9}'`
        sleep 1
        NEW_IN=`ifconfig $eth |awk -F'[: ]+' '/bytes/{if(NR==4)print $6;else if(NR==8)print $4}'`
        NEW_OUT=`ifconfig $eth |awk -F'[: ]+' '/bytes/{if(NR==6)print $6;else if(NR==8)print $9}'`
	echo "IN: "$((${NEW_IN}-${OLD_IN}))
	echo "OUT:"$((${NEW_OUT}-${OLD_OUT}))
        IN=`awk 'BEGIN{printf "%.1f\n",'$((${NEW_IN}-${OLD_IN}))'/1024/128}'`
        OUT=`awk 'BEGIN{printf "%.1f\n",'$((${NEW_OUT}-${OLD_OUT}))'/1024/128}'`
        echo "${IN}MB/s ${OUT}MB/s"

        i=$(($i+1))
        sleep 1
    done
    
    echo "---------------------------------------"
}

main(){
    if [ $LOGNAME != root ]; then
        echo "Please use the root account operation."
        exit 1
    fi
    
    tool_check
     
    while true; do
        select input in cpu_load cpu_top10 mem_use mem_top10 disk_load disk_use disk_inode tcp_status traffic quit; do
            case $input in
                cpu_load)
                    #CPU利用率与负载
                    cpu_load
                    break
                    ;;
                cpu_top10)
                    #占用CPU高的前10个进程
                    cpu_top10
                    break
                    ;;
                mem_use)
                    #内存利用率
                    mem_use
                    break
                    ;;
                mem_top10)
                    #占用内存高的前10个进程
                    mem_top10
                    break
                    ;;
                disk_load)
                    #硬盘I/O负载
                    disk_load
                    break
                    ;;
                disk_use)
                    #硬盘利用率
                    disk_use
                    break
                    ;;
                disk_inode)
                    #硬盘inode利用率
                    disk_inode
                    break
                    ;;
                tcp_status)
                    #网络连接状态
                    tcp_status
                    break
                    ;;
                traffic)
                    #查看网络流量
                    net_traffic    
                    break
                    ;;
                quit)
                    exit 0
                    ;;
                *)
                    echo "---------------------------------------"
                    echo "Please enter the number." 
                    echo "---------------------------------------"
                    break
                    ;;
            esac
        done
    done
}

main
