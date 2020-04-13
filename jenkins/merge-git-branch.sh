#!/bin/bash
#zk
#auto merge
#$1是更新目录
#$2是要合并的分支（如develop）
#$3是要被合并分支（如master）
#将$2分支合并到$3分支
echo $1  mmt-wxapp
echo $2  feature_0410
echo $3  pre_master
var=$1
cd /data/code/$1
pwd
echo 123qweASD | sudo -S  git checkout pre_master
sudo git pull -f
sudo git checkout feature_0410
sudo git pull -f
sudo git checkout pre_master
sudo git merge feature_0410 --no-ff
if [ $? -eq 0 ];then
        sudo git push
        echo ++++++++++++++++++++++++++++++++++++++MERGE SUCCESS+++++++++++++++++++++++++++++++++++++++++
        exit 0
else
        url=`git config --list | grep 'remote.origin.url' | cut -d'=' -f2`
        echo $1
        echo $url

        cd ..
        
        echo 123qweASD | sudo -S rm -rf $1
        echo 123qweASD | sudo -S git clone $url
        exit 1
fi
