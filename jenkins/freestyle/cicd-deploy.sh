#!/bin/bash
source /etc/profile

baseFolder='/your/path/sprint'
serviceName='yourservice'
packageName='ROOT'

CURDIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
cd $CURDIR


if [ -d mixmedia ]; then
  rm -rf mixmedia
fi

echo deploy the ${packageName}.war!!!
unzip ${packageName}.war -d mixmedia
