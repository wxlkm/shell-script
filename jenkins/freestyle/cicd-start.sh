#!/bin/bash

source /etc/profile

CURDIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
cd $CURDIR

./cicd.sh start
