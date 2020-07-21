#!/bin/sh
#author_name="# Mirza Golam Abbas Shahneel"
version="#1.0.0"
modifiedp="# Modified_21072020_1711";
modified="# Modified_21072020_1711";
versionDate="21-JUL-2020 17:11";
#No Colors
NC='\033[0m'              # Text Reset/No Color
# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellowecho
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White
# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White
# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White
# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White
# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White
# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White
# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White
spaceVal='  '

echo -e "${BRed} Script Updated On $versionDate ${NC}"

YUM_CONF='/etc/yum.conf';
MONGODB_REPO='/etc/yum.repos.d/mongodb-org-4.2.repo';
MONGODB_CONF='/etc/mongod.conf';
mongoInstallTrial=0;

function fn_osinfo()
{
for i in $(ls /etc/*release);
	do
		if [ $i == '/etc/centos-release' ] || [ $i == '/etc/redhat-release' ] || [ $i == '/etc/system-release' ];then
			cat $i | awk '{print $1}' > os_name;	
			osn=$(<os_name);	
			rm -f os_name;
			
			if [ -z "${osn}" ]
			then			
				v=$(lsb_release -a | awk '{print $2}' | head -2 | tail -1 );
				if [ $v  == "Ubuntu" ]
				then
					echo -e "${BPurple} OS name: $v ${NC}\n"
					osType=3;
				else
					echo -e "${BPurple} Undefined os: $v ${NC}\n"
					osType=4;
				fi	
			fi
			
			if [ $osn  == "Red" ]
			then
				echo -e "${BPurple} OS: $osn ${NC}\n"
				osType=1;
			fi
			
			if [ $osn  == "CentOS" ]
			then
				echo -e "${BPurple} OS: $osn ${NC}\n"
				osType=2;
				fn_mongod_cnf;
			fi
		fi
		if [ $osType != 0 ];then
			break;
		fi
	done
}

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
};
echo -e "${BBlue} Running MongoDB Installer version $version ${NC}\n"
fn_osinfo;