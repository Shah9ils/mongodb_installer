YUM_CONF='/etc/yum.conf';
MONGODB_REPO='/etc/yum.repos.d/mongodb-org-4.2.repo';
MONGODB_CONF='/etc/mongod.conf';
mongoInstallTrial=0;

function fn_mongodb_yum(){
	
	sed -i '/exclude=mongodb-org,mongodb-org-server,mongodb-org-shell,mongodb-org-mongos,mongodb-org-tools/d' $YUM_CONF
	
	echo "[mongodb-org-4.2]" > $MONGODB_REPO
	echo "name=MongoDB Repository" >> $MONGODB_REPO
	echo "baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.2/x86_64/" >> $MONGODB_REPO
	echo "gpgcheck=1" >> $MONGODB_REPO
	echo "enabled=1" >> $MONGODB_REPO
	echo "gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc" >> $MONGODB_REPO

	sudo yum install -y mongodb-org

	chkMongoExclusionYum=$(cat $YUM_CONF | grep mongo);
	if [ -z $chkMongoExclusionYum ];then
		echo "exclude=mongodb-org,mongodb-org-server,mongodb-org-shell,mongodb-org-mongos,mongodb-org-tools" >> $YUM_CONF
		echo "DISABLED AUTO UPDATE FOR MongoDB";
	else
		echo "FOUND $chkMongoExclusionYum";
		echo "NO CHANGES DONE $YUM_CONF";
	fi

	sudo service mongod start
	sudo chkconfig mongod on
	# TODO: Check if mongod installed if not prompt user
	mongo --eval "printjson(db.serverStatus().version)";
	# mongoInstallTrial=1;

}

function fn_mongodb_rpm(){
	rm -rf /home/mongo_resource
	mkdir /home/mongo_resource
	cd /home/mongo_resource
	
	wget --no-check-certificate https://repo.mongodb.org/yum/redhat/6Server/mongodb-org/4.2/x86_64/RPMS/mongodb-org-tools-4.2.6-1.el6.x86_64.rpm
	wget --no-check-certificate https://repo.mongodb.org/yum/redhat/6Server/mongodb-org/4.2/x86_64/RPMS/mongodb-org-shell-4.2.6-1.el6.x86_64.rpm
	wget --no-check-certificate https://repo.mongodb.org/yum/redhat/6Server/mongodb-org/4.2/x86_64/RPMS/mongodb-org-mongos-4.2.6-1.el6.x86_64.rpm
	wget --no-check-certificate https://repo.mongodb.org/yum/redhat/6Server/mongodb-org/4.2/x86_64/RPMS/mongodb-org-server-4.2.6-1.el6.x86_64.rpm
	wget --no-check-certificate https://repo.mongodb.org/yum/redhat/6Server/mongodb-org/4.2/x86_64/RPMS/mongodb-org-4.2.6-1.el6.x86_64.rpm

	rpm -ivh mongodb-org-server-4.2.6-1.el6.x86_64.rpm
	rpm -ivh mongodb-org-mongos-4.2.6-1.el6.x86_64.rpm
	rpm -ivh mongodb-org-shell-4.2.6-1.el6.x86_64.rpm
	rpm -ivh mongodb-org-tools-4.2.6-1.el6.x86_64.rpm
	rpm -ivh mongodb-org-4.2.6-1.el6.x86_64.rpm

	sudo service mongod start
	sudo chkconfig mongod on
	
	mongo --eval "printjson(db.serverStatus().version)";
	# mongoInstallTrial=1;
	cd -
}


function fn_mongo_install_menu(){
	while :
	  do
		clear
		# if [ $flg_sleep -eq 0 ]
			# then
			  # flg_sleep=1;
			  # #time_out;
			  # pwd > pw;
			  # var_rm=$(<pw);
			  # var_rm="$var_rm/binstaller";
			  # rm -f $var_rm;
			  # rm -f pw;
		# fi
		#echo -e "\033[1m "

		echo -e "\033[34m  _____________________________________";
		echo -e "\033[34m |\033[35m \033[1m          Install MongoDB          \033[0m \033[34m|";
		echo -e "\033[34m |_____________________________________|";
		echo -e "\033[34m | \033[32m [1] Install with YUM (v4.2+)  \033[34m     |";
		echo -e "\033[34m | \033[32m [2] Install with RPM (v4.2.6) \033[34m     |";
		if [ $mongoInstallTrial -eq 1 ]; then
			echo -e "\033[34m | \033[31m [0] Exit/Stop                 \033[34m     |"
		fi
		echo -e "\033[34m |_____________________________________|"
		if [ $mongoInstallTrial -eq 1 ]; then
			echo -e -n "\033[35m  Select the task [1 or 2] or '0' for exit: \033[0m"
		else
			echo -e -n "\033[35m  Select the task [1 or 2] \033[0m"
		fi

		read installMethod;
		case $installMethod in
		1)
			fn_mongodb_yum;
			mongoInstallTrial=1;
		echo "Press enter to exit."
		read
		;;
		
		
		2)
			fn_mongodb_rpm;
			mongoInstallTrial=1;
		echo "Press enter to exit."
		read
		;;
		
		0) exit 0 ;;
			  
			*) echo "Please select number at least one option"; read ;;

	   esac
	done
}


function fn_mongod_cnf(){
	find /etc -name mongod.conf | grep mongod.conf && var_MONGODB_CONF=1 || var_MONGODB_CONF=0;
	find /var/lib  -name mongo | grep mongo && var_mongo=1 || var_mongo=0;
	
	if [ $var_mongo -eq 1 ] && [ $var_MONGODB_CONF -eq 1 ];then
		MongoDB_v=$(mongo --eval "printjson(db.serverStatus().version)" | grep "server version" | gawk -F: '{print $2}');
		echo "MongoDB $MongoDB_v exists";
	elif [ $var_mongo -eq 1 ] && [ $var_MONGODB_CONF -eq 0 ];then
		MongoDB_v=$(mongo --eval "printjson(db.serverStatus().version)" | grep "server version" | gawk -F: '{print $2}');
		echo "MongoDB $MongoDB_v exists! Please configure $MONGODB_CONF";
	elif [ $var_mongo -eq 0 ];then
		echo "Installing MongoDB";
		fn_mongo_install_menu;
	else
		echo "Configuring $MONGODB_CONF";
	fi
}

fn_mongod_cnf;