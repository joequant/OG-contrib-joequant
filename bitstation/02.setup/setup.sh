#!/bin/bash -v
# Setup and configure website to use giving configuration

WEB_DIR=/home/user/git/bitquant/bitstation/web

# use ls because stat causes error on dockerhub
ME=user
GROUP=user

pushd $WEB_DIR > /dev/null

pushd /var/www/html > /dev/null
rm -f *
for i in index.html css data fonts js ; do
ln -s -f  ../../..$WEB_DIR/$i $i
done
popd > /dev/null

# Do a special copy so that suexec works
pushd /var/www/cgi-bin > /dev/null
rm -rf /var/www/cgi-bin/*
for i in $WEB_DIR/cgi-bin/*; do
cp -r ../../..$WEB_DIR/cgi-bin/$(basename $i) $(basename $i)
chown -R $ME:$GROUP $(basename $i)
done
popd > /dev/null

pushd /etc/httpd/conf/webapps.d > /dev/null
if [ -f 00_default_vhosts.conf ] ; then
mv -f 00_default_vhosts.conf 00_default_vhosts.conf.bak
fi
popd > /dev/null

# Create root copy of scripts
rm -rf /usr/share/bitquant
mkdir -p /usr/share/bitquant
cp $WEB_DIR/scripts/environment.sh /usr/share/bitquant
cp $WEB_DIR/cgi-bin/bittrader/conf.sh /usr/share/bitquant
cp $WEB_DIR/cgi-bin/bittrader/timezone.sh /usr/share/bitquant
chown $ME:$GROUP /usr/share/bitquant/environment.sh
chmod o-w /usr/share/bitquant/*.sh