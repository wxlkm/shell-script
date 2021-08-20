#!/bin/bash
source /etc/profile

baseFolder='/u01/isi/sprint'
serviceName='resource'
packageName='ROOT'

CURDIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
cd $CURDIR


if [ -d mixmedia ]; then
  rm -rf mixmedia
fi

echo deploy the ${packageName}.war!!!
unzip ${packageName}.war -d mixmedia
