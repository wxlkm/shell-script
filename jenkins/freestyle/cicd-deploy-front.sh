#!/bin/bash
source /etc/profile

baseFolder='/u01/isi/sprint'
serviceName='/manage-front'
packageName='dist'

backuptime=`date +%Y%m%d%H%M%S`

if [ -d ${baseFolder}/${serviceName}/${packageName} ]; then
  rm -rf ${baseFolder}/${serviceName}/${packageName}
fi

echo deploy the dist!!!
tar -zxvf ${baseFolder}/${serviceName}/${packageName}.tar.gz -C ${baseFolder}/${serviceName}/
