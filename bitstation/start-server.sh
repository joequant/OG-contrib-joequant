#!/bin/bash

IMAGE=joequant/bitstation
if [ "$1" != "" ] ; then
   IMAGE=$1
fi

if [ "$BTQNT_IMAGE_DIR" == "" ] ; then
    BTQNT_IMAGE_DIR=bitstation-vol
fi

$SUDO docker run -t -i \
      -v $BTQNT_IMAGE_DIR-home:/home \
      -v $BTQNT_IMAGE_DIR-dokuwiki:/var/lib/dokuwiki \
      -v $BTQNT_IMAGE_DIR-mongodb:/var/lib/mongodb \
      -v $BTQNT_IMAGE_DIR-redis:/var/lib/redis \
      -v $BTQNT_IMAGE_DIR-bitcoin:/var/lib/bitcoin \
      -v $BTQNT_IMAGE_DIR-log:/var/log \
      -v $BTQNT_IMAGE_DIR-etc:/etc \
      -v $BTQNT_IMAGE_DIR-srv:/srv \
      -p 80:80 -p 443:443 $IMAGE >& docker.log &
echo "Docker started"

