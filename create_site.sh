#!/bin/bash

# Directories
##########################################################
HTTPDIR="/var/www/html/"

# get the site name ($SITENAME)
echo "Please, enter the site name:"
read SITENAME
if [$SITENAME = ""]; then
	echo -n "Enter the site name and press [ENTER]: "
	exit -1
else
	echo -n "the site name is $SITENAME"
fi

function siteName {
for $SITENAME = "" ; do
	echo "Please, enter the site name:"
	while [ "$SITENAME" = "" ]; do
		echo "Please, enter the site name:"
	done
	read SITENAME
done
}

# get the directory name ($ROOTDIR)
function rootDir {
for $SITESLOGAN = "" ; do
	echo "Please, enter the new site name (no spaces)"
	read ROOTDIR
	if [ "$ROOTDIR" = "" ]; then
	ROOTDIR=testing site on V-Zend
	fi
done
}


# get the site slogan ($SITESLOGAN)
function siteSlogan {
for $SITESLOGAN = "" ; do
	echo "Please, enter the new site slogan:"
	read SITESLOGAN
	if [ "$SITESLOGAN" = "" ]; then
	SITESLOGAN=testing site on V-Zend
	fi
done
}

echo "Please, enter the site name:"
while [ "$SITENAME" = "" ]; do
	echo "Please, enter the site name:"
done
read SITENAME


SITELOCALE="gb"
##########################################################
# Database
##########################################################
dbHost="localhost"
dbName=$ROOTDIR # change of the dbName for Every NEW site
dbUser="root"
dbPassword="*xxxxxx"
##########################################################
# Admin
##########################################################
AdminUsername="admin"
AdminPassword="admin"
adminEmail="jean-paul.mutuyimana@wto.org"

##########################################################
# Functions
##########################################################
		
# 1. Prepare databases
##########################################################
function droptables {
# this hack is from http://www.thingy-ma-jig.co.uk/blog/10-10-2006/mysql-drop-all-tables
mysqldump -u $dbUser -p$dbPassword --add-drop-table --no-data $dbName | grep ^DROP | mysql -u $dbUser -p$dbPassword $dbName
}
# 2. Create databases
##########################################################
function createdb {
	echo "";
	echo "check whether the database exists\a\n"
	DB_EXISTS=`mysql -u $dbUser -p$dbPassword -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '$dbName'" | wc -c`
	if [ $DB_EXISTS = 1 ]; then	
		echo "** Drupal database $dbName exists, drop tables...\a\n"
		echo -e 'Are you sure, that you want to drop tables? (y/n) '
		read DO_DROP
		if [ $DO_DROP = y ]; then
			droptables
		else
			echo -e 'The script does not drop tables\n'
		fi
	fi
}



if [ $HTTPDIR/$ROOTDIR = 0 ]; then
	echo $ROOTDIR' exists, are you sure you want to overwrite it? (y/n)'
	read input
		if [[ $input == "Y" || $input == "y" ]; then
		echo -e "CONTINUE THE INSTALLATION \n"
		createdb
		##########################################################
		# CONTINUE the installation
		##########################################################
		
		# Download Core
		##########################################################
		drush dl -y site_starter --destination=$HTTPDIR --drupal-project-rename=$ROOTDIR;
		
		# Prepare settings file and folder
		##########################################################
		echo -e '** prepare Drupal setting files...\n' 
			if [ ! -e $HTTPDIR/$ROOTDIR/sites/default/settings.php ]; then
				cp $HTTPDIR/$ROOTDIR/sites/default/default.settings.php $HTTPDIR/$ROOTDIR/sites/default/settings.php
			fi;
		chmod a+w $HTTPDIR/$ROOTDIR/sites/default/;
		chmod a+w $HTTPDIR/$ROOTDIR/sites/default/settings.php;

		cd $HTTPDIR/$ROOTDIR;
		pwd;
			
		# Install core
		##########################################################
		drush site-install site_starter --account-mail=$adminEmail --account-name=$AdminUsername --account-pass=$AdminPassword --site-name=$SITENAME --site-mail=$adminEmail --locale=$SITELOCALE --db-url=mysql://$dbUser:$dbPassword@$dbHost/$dbName;
		
		# Download modules and themes
		##########################################################
		drush -y dl \
		devel \
		module_filter \
		conditional_styles \
		ds \
		jquery_update \
		webform \
		print ;
		
		# Disable some core modules
		##########################################################
		drush -y dis \
		color \
		toolbar \
		shortcut ;
		
		# Enable modules
		##########################################################
		drush -y en \
		devel \
		module_filter \
		conditional_styles \
		ds \
		jquery_update \
		webform \
		print ;
		
		# Pre configure settings
		##########################################################
		# disable user pictures
		drush vset -y user_pictures 0;
		# allow only admins to register users
		drush vset -y user_register 0;
		# set site slogan
		drush vset -y site_slogan $SITESLOGAN;
		# Configure JQuery update 
		drush vset -y jquery_update_compression_type "min";
		drush vset -y jquery_update_jquery_cdn "google";
		drush -y eval "variable_set('jquery_update_jquery_version', strval(1.7));"

		##########################################################
		# Drupal run first update
		##########################################################
		echo ""
		echo -e '** Updating drupal using drush...\n'
		drush up -y;
		drush cc all;

		else
		##########################################################
		# END the installation
		##########################################################
			echo ""
			echo -e "files and folders will not be overwriten. Stopping this script!! Creation of "$ROOTDIR "INCOMPLETE\n"
		fi
fi
echo ""
echo  "////////////////////////////////////////////////////"
echo  "// END of script"
echo -e "////////////////////////////////////////////////////\n"
while true; do
read -p "press enter to exit" yn
case $yn in
* ) exit;;
esac
done

## testings
while true; do
    read -p "Do you wish to install this program?" yn
    case $yn in
        [Yy]* ) make install; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
