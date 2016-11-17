#!/bin/bash

echo "=> Starting MySQL"
/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for MySQL startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL admin with ${_word} password"

mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"

# You can create a /mysql-setup.sh file to intialized the DB
if [ -f /mysql-setup.sh ] ; then
	echo "=> Intializing the database"
	. /mysql-setup.sh
fi

echo "=> Done!"

echo "================================================"
echo "You can now connect to this MySQL Server using:"
echo "   mysql -uadmin -p$PASS -h<host> -P<port>"
echo "Please remember to change the above password!"
echo "MySQL user 'root' has no password"
echo "================================================"

echo "=> Shutting down MySQL"
mysqladmin -uroot shutdown