#!/bin/bash

STANDART_REMINE_NAME="redmine-2.6"
STANDART_REMINE_DB_NAME="redmine26"
DOMAIN_NAME_PREFIX="rm-26"
REMINES_ROOT_PATH="/usr/share/srv-redmine/"
NEW_REMINE_ROOT_PATH=$REMINES_ROOT_PATH$STANDART_REMINE_NAME"-"$1
APACHE2_DIR="/etc/apache2"
MYSQL_PASS="xTp68zw73"

HOST_CONF="<VirtualHost *:80>
    ServerName $DOMAIN_NAME_PREFIX-$1.local
    ServerAdmin vladimir@pitin.su
    DocumentRoot $NEW_REMINE_ROOT_PATH/public
    Options Indexes ExecCGI FollowSymLinks
    PassengerResolveSymlinksInDocumentRoot on
    #RailsEnv production
    RailsEnv development
    RailsBaseURI /

    CustomLog /var/log/apache2/$DOMAIN_NAME_PREFIX-$1.local-access.log common
    ErrorLog /var/log/apache2/$DOMAIN_NAME_PREFIX-$1.local-error.log

    <Directory $NEW_REMINE_ROOT_PATH/public>
        AllowOverride all
        Options -MultiViews
    </Directory>

</VirtualHost>"


mkdir $REMINES_ROOT_PATH$STANDART_REMINE_NAME"-"$1
cp -R $REMINES_ROOT_PATH$STANDART_REMINE_NAME/* $NEW_REMINE_ROOT_PATH
sed -i -e 's/redmine26-database/'$STANDART_REMINE_DB_NAME$1'/g' $NEW_REMINE_ROOT_PATH"/config/database.yml"
chown -R www-data:user $NEW_REMINE_ROOT_PATH

mysql -uroot -p${MYSQL_PASS} --execute="CREATE DATABASE $STANDART_REMINE_DB_NAME$1 CHARACTER SET utf8;"

/home/user/.rvm/bin/rake -f $NEW_REMINE_ROOT_PATH/Rakefile generate_secret_token
/home/user/.rvm/bin/rake -f $NEW_REMINE_ROOT_PATH/Rakefile db:migrate RAILS_ENV=production
/home/user/.rvm/bin/rake -f $NEW_REMINE_ROOT_PATH/Rakefile redmine:load_default_data RAILS_ENV=production REDMINE_LANG=en

touch ${APACHE2_DIR}"/sites-available/"${DOMAIN_NAME_PREFIX}"-"$1
echo "$HOST_CONF" >> ${APACHE2_DIR}"/sites-available/"${DOMAIN_NAME_PREFIX}"-"$1
a2ensite ${DOMAIN_NAME_PREFIX}"-"$1

service apache2 restart

echo "Redmine instance "$STANDART_REMINE_NAME"-"$1"has been created"

