#!/bin/bash

name='nginx-1.18.0'
path='/opt/app'

nginx_path=$path'/nginx'
tmp_path=$path'/tmp'

mkdir -p $nginx_path
mkdir -p $tmp_path

useradd  -s /sbin/nologin nginx
yum install -y gcc pcre-devel gd-devel openssl-devel

wget -O /opt/app/tmp/$name.tar.gz http://nginx.org/download/$name.tar.gz

tar -zxvf /opt/app/tmp/$name.tar.gz -C /opt/app/tmp/

cd "$tmp_path/$name"
pwd

./configure --prefix=$nginx_path --user=nginx --group=nginx --error-log-path=$nginx_path/logs/error.log --http-log-path=$nginx_path/logs/access.log --with-http_ssl_module --with-http_realip_module --with-http_flv_module --with-http_gzip_static_module --with-http_gunzip_module --with-http_stub_status_module --with-http_sub_module --with-stream

make && make install
