#!/bin/bash

# get kernel version"
RELEASE_VERSION=$(rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release))

# configure yum source"
cd /etc/yum.repos.d/
mkdir /etc/yum.repos.d/bak
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak &>/dev/null

if [ $RELEASE_VERSION -eq 6 ]; then
        curl -o /etc/yum.repos.d/My-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo &>/dev/null
fi

if [ $RELEASE_VERSION -eq 7 ]; then
        curl -o /etc/yum.repos.d/My-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo &>/dev/null
fi

yum clean all
yum makecache

# install epel
yum list | grep epel-release
yum install -y epel-release

# update rpm package include kernel"
yum -y update
rm -rf /etc/yum.repos.d/CentOS*

# set timezone"
test -f /etc/localtime && rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# set LANG"
if [ $RELEASE_VERSION -eq 6 ]; then
        sed -i 's@LANG=.*$@LANG="en_US.UTF-8"@g' /etc/sysconfig/i18n
fi

if [ $RELEASE_VERSION -eq 7 ]; then
        sed -i 's@LANG=.*$@LANG="en_US.UTF-8"@g' /etc/locale.conf
fi

# update time"
if [ $RELEASE_VERSION -eq 6 ]; then
        /usr/sbin/ntpdate -b pool.ntp.org
        grep -q ntpdate /var/spool/cron/root
        if [ $? -ne 0 ]; then
                echo '* * * * * /usr/sbin/ntpdate pool.ntp.org &>/dev/null'>/var/spool/cron/root
                chmod 600/var/spool/cron/root
        fi
        /etc/init.d/crond restart
fi

if [ $RELEASE_VERSION -eq 7 ]; then
        yum -y install chrony
        > /etc/chrony.conf
        cat >>/etc/chrony.conf <<-EOF
        server pool.ntp.org iburst
        stratumweight 0
        driftfile /var/lib/chrony/drift
        rtcsync
        makestep 10 3
        bindcmdaddress 127.0.0.1
        bindcmdaddress ::1
        keyfile /etc/chrony.keys
        commandkey 1
        generatecommandkey
        noclientlog
        logchange 0.5
        logdir /var/log/chrony
        EOF
        systemctl restart chronyd
        systemctl enable chronyd
fi

# clean iptables default rules"
if [ $RELEASE_VERSION -eq 6 ]; then
        /sbin/iptables -F
        service iptables save
        chkconfig iptables off
fi

if [ $RELEASE_VERSION -eq 7 ]; then
        systemctl disable firewalld
fi

#disable unused service"
if [ $RELEASE_VERSION -eq 6 ]; then
        chkconfig auditd off
fi

if [ $RELEASE_VERSION -eq 7 ]; then
        systemctl disable auditd
fi

#disable ipv6"
if [ $RELEASE_VERSION -eq 6 ]; then
        cd /etc/modprobe.d/ && touch ipv6.conf
        > /etc/modprobe.d/ipv6.conf
        cat >> /etc/modprobe.d/ipv6.conf <<-EOF
        alias net-pf-10 off
        options ipv6 disable=1
        EOF
fi

if [ $RELEASE_VERSION -eq 7 ]; then
        sed -ri 's/(GRUB_CMDLINE_LINUX=")/\1ipv6\.disable=1 /g' /etc/default/grub
        grub2-mkconfig -o /boot/grub2/grub.cfg
fi


# disable SELINUX"
setenforce 0
sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config

# update record command"
sed -r 's/^HISTSIZE=.*$/HISTSIZE=5000/' /etc/profile
if ! grep HISTTIMEFORMAT /etc/profile; then
        echo 'export HISTTIMEFORMAT="%F %T `whoami` "' >> /etc/profile
fi

# SSH超时时间
if ! grep "TMOUT=600" /etc/profile &>/dev/null; then
    echo "export TMOUT=600" >> /etc/profile
fi

# SSH禁用DNS和GSS验证
sed -ri '/^#UseDNS/cUseDNS no' /etc/ssh/sshd_config
sed -ri '/^GSSAPIAuthentication/cGSSAPIAuthentication no' /etc/ssh/sshd_config

# update ulimit configure"
if [ $RELEASE_VERSION -eq 6 ];then
        test -f /etc/security/limits.d/90-nproc.conf && rm -rf /etc/security/limits.d/90-nproc.conf && touch /etc/security/limits.d/90-nproc.conf
fi

if [ $RELEASE_VERSION -eq 7 ]; then
        test -f /etc/security/limits.d/20-nproc.conf && rm -rf /etc/security/limits.d/20-nproc.conf && touch /etc/security/limits.d/20-nproc.conf
fi

> /etc/security/limits.conf
cat >>/etc/security/limits.conf <<-EOF

* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
EOF

# update /etc/sysctl.conf"
cat >> /etc/sysctl.conf <<-EOF
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_tw_buckets = 20480
net.ipv4.tcp_max_syn_backlog = 20480
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_fin_timeout = 20
EOF

# 减少SWAP使用"
cat >> /etc/sysctl.conf <<-EOF

vm.swappiness = 10
EOF

# 安装系统性能分析工具及其他
#yum -y install epel-release
#yum -y install gcc make autoconf vim net-tools lrzsz 
#yum -y install nc sysstat iftop iotop iostat dstat tcpdump
#yum -y install ipmitool bind-libs bind-utils
#yum -y install libselinux-python


