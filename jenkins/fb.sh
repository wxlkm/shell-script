#!/bin/bash

project_path="/u01/isi/sprint"

#所有应用jar包名称
app_rongbian="dist.tar.gz"
app_portal="sprint-mixmedia-portal.jar"
app_resource="ROOT.war"
app_site="mixmedia-site.jar"
app_uumst="sprint-uumst.jar"
app_manage="mixmedia-manage.jar"
app_ucm="mixmedia-ucm.jar"
app_manage_front="dist.tar.gz"
app_mobile="hq-sprint-mobile.jar"

deploy-web() {
    host="sprint2_${1//-/_}"
    app_path="$1"
    app_name="$2"
    echo "###############################################################"
    echo "###$(date +'%F %T') deploy $host###"|tee -a /u01/isi/jenkins/project/cicd.log
    ansible $host -m shell -a "${project_path}/${app_path}/cicd-backup.sh" | tee -a /u01/isi/jenkins/project/cicd.log
    ansible $host -m copy -a "src=/u01/isi/jenkins/project/sprint2/${app_path}/${app_name} dest=/u01/isi/sprint/${app_path}/" | tee -a /u01/isi/jenkins/project/cicd.log
    ansible $host -m shell -a "${project_path}/${app_path}/cicd-deploy.sh" | tee -a /u01/isi/jenkins/project/cicd.log
}

deploy-jar-test() {
    host="sprint2_${1//-/_}"
    app_path="$1"
    app_name="$2"
    ansible -m ping $host
}

deploy-jar() {
    host="sprint2_${1//-/_}"
    app_path="$1"
    app_name="$2"
    echo "###############################################################"
    echo "###$(date +'%F %T') deploy $host###" | tee -a /u01/isi/jenkins/project/cicd.log
    ansible $host -m shell -a "${project_path}/${app_path}/cicd-stop.sh" | tee -a /u01/isi/jenkins/project/cicd.log
    ansible $host -m shell -a "${project_path}/${app_path}/cicd-backup.sh" | tee -a /u01/isi/jenkins/project/cicd.log
    ansible $host -m copy -a "src=/u01/isi/jenkins/project/sprint2/${app_path}/${app_name} dest=/u01/isi/sprint/${app_path}/" | tee -a /u01/isi/jenkins/project/cicd.log
    ansible $host -m shell -a "${project_path}/${app_path}/cicd-start.sh" | tee -a /u01/isi/jenkins/project/cicd.log
}


case $1 in
    "portal")
	deploy-jar $1 ${app_portal}
        ;;
    "site")
	deploy-jar $1 ${app_site}
        ;;
    "uumst")
	deploy-jar $1 ${app_uumst}
        ;;
    "manage")
	deploy-jar $1 ${app_manage}
        ;;
    "ucm")
	deploy-jar $1 ${app_ucm}
        ;;
    "mobile")
	deploy-jar $1 ${app_mobile}
        ;;
    "manage-front")
	deploy-web $1 ${app_manage_front}
        ;;
    "resource")
	deploy-web $1 ${app_resource}
        ;;
    "rongbian")
	deploy-web $1 ${app_rongbian}
        ;;
    *)
    echo "error!"
    ;;
esac
