#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"
    /create_mysql_admin_user.sh
else
    echo "=> Using an existing volume of MySQL"
fi

# Create the ownCloud database if it doesn't exist.
if [[ ! -d $VOLUME_HOME/owncloud ]]; then

    # Start MySQL
    /usr/bin/mysqld_safe > /dev/null 2>&1 &

    RET=1
    while [[ RET -ne 0 ]]; do
        echo "=> Waiting for confirmation of MySQL service startup"
        sleep 5
        mysql -uroot -e "status" > /dev/null 2>&1
        RET=$?
    done

    OWNCLOUD_DB="owncloud"

    # If not supplied, generate a random password for the owncloud MySQL user.
    OWNCLOUD_PASSWORD=${OWNCLOUD_PASS:-$(pwgen -s 12 1)}

    echo "========================================================================"
    echo
    echo "MySQL owncloud user password:" $OWNCLOUD_PASSWORD
    echo
    echo "========================================================================"


    # Create the database
    mysql -uroot -e "CREATE DATABASE owncloud; \
            GRANT ALL PRIVILEGES ON owncloud.* TO 'owncloud'@'localhost' \
            IDENTIFIED BY '$OWNCLOUD_PASSWORD'; FLUSH PRIVILEGES;"

    mysqladmin -uroot shutdown
    sleep 5
fi

# Update Apache permissions.
sed -i 's/AllowOverride None/AllowOverride All/g' \
            /etc/apache2/sites-available/000-default.conf
sed -i 's/AllowOverride Limit/AllowOverride All/g' \
            /etc/apache2/sites-available/000-default.conf

# If the application directory is empty, copy the site.
APPLICATION_HOME="/var/www/html"

if [ ! "$(ls -A $APPLICATION_HOME)" ]; then
    # Copy the application folder.
    cp -r /owncloud/* $APPLICATION_HOME
    cp /owncloud/.htaccess $APPLICATION_HOME

    # Update ownership.
    chown -R www-data /var/www/html
fi

exec supervisord -n
