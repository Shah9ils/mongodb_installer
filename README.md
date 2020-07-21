# mongodb_installer

#### Installation

* Just download the "mongodb_installer" file in RHEL/CentOS based server.
* Give executable permission to the downloaded file.
* Run the file 
```
	rm -f mongo_installer.sh
	https://raw.githubusercontent.com/Shah9il/mongodb_installer/master/mongo_installer.sh
	chmod a+x mongo_installer.sh
	sh mongo_installer.sh
```
* If MongoDB is not already installed then following menu should be available

	Install MongoDB|
	------------|
	[1] Install with YUM (v4.2+)  |
	[2] Install with RPM (v4.2.6) |
	[0] Exit/Stop                 |

* Select [1] to install MongoDB using YUM repo or [2] to download and install RPM resources

#### Pre-requisite

* Script to be run in RHEL/CentOS servers. For others OSs script yet to be modified.