#!/bin/bash
#author: wxlkm
#help to config yum
#2018-3-23

backup_dir="/etc/yum.repos.d/"`date +%F`"-backup"
mkdir $backup_dir
mv /etc/yum.repos.d/*.repo $backup_dir

linux_version=$(cat /etc/redhat-release | awk '{print $4}'| awk -F"." '{print $1}')


echo "################################"
echo -e "\t1 install aliyun mirrors"
echo -e "\t2 install self-construct mirrors"
echo -e "\t3 install self-construct ceph mirrors"
echo -e "\tq exit"
echo "################################"

read -p "select the mirror's type: " mirror_type
if [ "$mirror_type" = "1" ]; then
	echo "install mirrors..."

	#if [ "$linux_version" = "7" ]; then
	#	curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo &>/dev/null
	#elif [ "$linux_version" = "6" ]; then
	#	curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo &>/dev/null
	#elif [ "$linux_version" = "8" ]; then
	#	curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo &>/dev/null
	#else
	#	echo "wrong linux version"
	#fi
	
	case "$linux_version" in
	"7")
		curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo &>/dev/null
		;;
	"6")
		curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo &>/dev/null
		;;
	"8")
		curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo &>/dev/null
		;;
	*)
		echo "wrong linux version"
		;;
	esac
	sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
	echo "aliyun mirrors installed"

elif [ "$mirror_type" = "3" ]; then
	if [ "$linux_version" = "7" ]; then
		cat >/etc/yum.repos.d/ceph.repo <<-EOF
		[ceph]
		name=ceph
		baseurl=http://192.168.0.180/ceph/rpm-nautilus/
		gpgcheck=0
		EOF
	fi
	
	echo "self-construct ceph mirrors installed"

else
	echo "mirror select wrong"
        exit
fi


echo "start to make cache..."

yum clean all &>/dev/null
yum makecache &>/dev/null

if [ $? -eq 0 ];then
	echo "mirror installed and cache maked successfully!"
else
	echo "There is something wrong. need debug!"
fi

