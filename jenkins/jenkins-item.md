Freestyle project
![图片](https://user-images.githubusercontent.com/58168483/130224366-9dd26387-bd40-4221-833f-84395d80a098.png)
![图片](https://user-images.githubusercontent.com/58168483/130224550-acb760ff-e0ef-4e52-a61b-70a87fddd237.png)
![图片](https://user-images.githubusercontent.com/58168483/130224595-d015c9e0-d1cf-4e2a-81e5-deba8d72f204.png)
![图片](https://user-images.githubusercontent.com/58168483/130224638-a05a5d9c-00dc-48e6-8ee8-f6d22baf13fc.png)
![图片](https://user-images.githubusercontent.com/58168483/130224762-20b62880-ca53-4bbf-9305-dae9e57bdc2c.png)


doBuild()

{  

	echo -e "\033[35m#编译阶段#\033[0m"

	cd ${WORKSPACE}

	if [ $mongosdb_core = "Yes" ];then
		echo -e "\033[35m#编译mongosdb-core#\033[0m"
    	pwd
		mvn -f sprint-common/pom.xml clean install
	fi

	if [ $sprint_ucm = "Yes" ];then
		echo -e "\033[35m#编译sprint-ucm#\033[0m"
    	pwd
		mvn -f sprint-ucm/pom.xml clean install
	fi
	
    echo -e "\033[35m#编译mixmedia-site#\033[0m"
    mvn -f mixmedia-site/pom.xml clean package
}

doCopyToHWNode()
{


	echo -e "\033[35m#传输阶段#\033[0m"
    echo -e "\033[35m#local file:mixmedia-site.jar#\033[0m"
    ls -l mixmedia-site/target/mixmedia-site.jar
    
    echo -e "#\033[35m传输mixmedia-site.jar#\033[0m"  
    rsync -avz -e "ssh -p 522 -i $HWID" mixmedia-site/target/mixmedia-site.jar $HWNODE:$HWREMOTE/project/sprint2/site/


}

doDeploy()
{


	echo -e "\033[35m#部署阶段#\033[0m"
    echo -e "\033[35m#发布site，并重启#\033[0m"
    ssh -p 522 -i $HWID $HWNODE "/u01/isi/jenkins/project/sprint2/fb.sh site"	


}


case $operation in


	"0")
    	echo -e "\033[35m无操作\033[0m"
        exit 0
        ;;
    
    "1")
    	doBuild
        doCopyToHWNode
    	;;
    
    "2")
    	doDeploy
    	;;

	*)
        echo -e "\033[35m参数错误！\033[0m"
        exit 1

esac
