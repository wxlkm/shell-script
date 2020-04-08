#!/bin/bash
###########################
#author:wxlkm
#java environment setup
#2018-3-23
###########################

install_java7() {
        echo "install java-1.7.0-openjdk......"
        yum -y install java-1.7.0-openjdk
        yum -y install java-1.7.0-openjdk-devel
}

install_java8() {
        echo "install java-1.8.0-openjdk......"
        yum -y install java-1.8.0-openjdk
        yum -y install java-1.8.0-openjdk-devel
}

install_java11() {
        echo "install java-11-openjdk......"
        yum -y install java-11-openjdk
        yum -y install java-11-openjdk-devel
}

java -version &>/dev/null

if [ $? -eq 0 ]
then
        for item in `yum list installed | grep java | awk '{print $1}' | grep -v noarch`
        do
                rpm -e --nodeps $item
        done
fi

while :
do
        echo "################################"
        echo -e "\t1 java-1.7.0-openjdk"
        echo -e "\t2 java-1.8.0-openjdk"
        echo -e "\t3 java-11-openjdk"
        echo -e "\tq exit"
        echo "################################"

        read -p "version[1-3]: " version
        if [ "$version" = "1" ];then
                install_java7
        elif [ "$version" = "2" ];then
                install_java8
        elif [ "$version" = "3" ];then
                install_java11
        elif [ "$version" = "q" ];then
                exit
        else
                echo "error"    
        fi
done
