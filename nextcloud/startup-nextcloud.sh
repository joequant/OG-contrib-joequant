#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INSTALLED_FILE=/var/lib/nextcloud/data/installed

crond &
sudo -u redis redis-server /etc/redis.conf --daemonize no >> /var/log/redis.log 2>&1 &

echo "waiting..."
/sbin/wait-for-it.sh db:5432
echo "connecting..."

if [ ! -e $INSTALLED_FILE ] ; then
    touch /etc/nextcloud/CAN_INSTALL
chown apache:apache -R /usr/share/nextcloud
pushd /usr/share/nextcloud
sudo -u apache php -d memory_limit=512M \
     occ maintenance:install \
     --database="pgsql" --database-name="nextcloud" \
     --database-host=${NEXTCLOUD_DB:-db} --database-user="postgres" \
     --database-pass="mypass" --admin-user="user" \
     --admin-pass="cubswin:)" --data-dir="/var/lib/nextcloud/data"
chown root:root -R /usr/share/nextcloud
sudo -u apache php occ config:system:set \
     trusted_domains 1 "--value=*"
sudo -u apache php occ background:cron

for app in \
    onlyoffice \
	calendar \
	maps \
	contacts \
	tasks \
	mail \
	notes \
	deck \
	quicknotes \
	groupfolders \
	files_texteditor \
	files_markdown \
	files_mindmap \
	user_external \
	ldap_write_support \
	cms_pico \
	sociallogin  \
	drawio \
	documentserver_community
do
sudo -u apache php -d memory_limit=512M \
     occ app:enable $app
done
popd

#update to nc19
#
# occweb

touch $INSTALLED_FILE
rm /etc/nextcloud/CAN_INSTALL
echo "If you get a 'ONLYOFFICE cannot be contacted.  Please contact admin.' error"
echo "Go into Setting > ONLYOFFICE and unset 'Document Editing Service address'"
fi

chown apache:apache -R /usr/share/nextcloud /var/lib/nextcloud /etc/nextcloud

echo "Restarting php-fpm"
/usr/sbin/php-fpm --nodaemonize --fpm-config /etc/php-fpm.conf >> /var/log/php-fpm.log 2>&1 &
/usr/sbin/httpd -DFOREGROUND



