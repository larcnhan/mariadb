#!/bin/sh

if [ -d /app/mariadb ]; then

	echo "[i] MySQL directory already present, skipping creation"
else 
	echo "[i] MySQL directory already present, skipping creation"
    
	# init database
    #mysql_install_db --user=mysql --datadir=/app/mysql > /dev/null
    mysql_install_db --user=root --datadir=/app/mariadb > /dev/null

	# set mysql root default password
    if [ "$MYSQL_ROOT_PASSWORD" = "" ]; then
    	MYSQL_ROOT_PASSWORD=111111
		echo "[i] MySQL root password : $MYSQL_ROOT_PASSWORD"
	fi
	
	# set database and user
	MYSQL_DATABASE=${MYSQL_DATABASE:-""}
	MYSQL_USER=${MYSQL_USER:-""}
	MYSQL_PASSWORD=${MYSQL_PASSWORD:-""}
    
	# create run dir
	if [ ! -d "/run/mysqld" ]; then
		mkdir -p /run/mysqld
	fi

	tfile=`mktemp`
	if [ ! -f "$tfile" ]; then
		return 1
	fi

	cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY "$MYSQL_ROOT_PASSWORD" WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("$MYSQL_ROOT_PASSWORD") WHERE user='root' AND host='localhost';
EOF

	if [ "$MYSQL_DATABASE" != "" ]; then
		echo "[i] Creating database: $MYSQL_DATABASE"
		echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile

		if [ "$MYSQL_USER" != "" ]; then
			echo "[i] Creating user: $MYSQL_USER with password $MYSQL_PASSWORD"
			echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
		fi
	fi

	/usr/bin/mysqld --user=root --bootstrap --verbose=0 < $tfile
	rm -f $tfile
fi

if [ ! -f /install/install.lock ]; then
    cp -R /install/* /etc/mysql/
    rm -rf /install/*
    touch /install/install.lock
fi

exec /usr/bin/mysqld --user=root --console
