#! /bin/sh

PROJ_PATH=/home/Server_Repo/DguWebp
APACHE_BIN_PATH=$PROJ_PATH/AkoMarket/apache8/logs


cd $APACHE_BIN_PATH
tail -f catalina.out

