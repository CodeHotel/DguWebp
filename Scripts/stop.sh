#! /bin/sh

PROJ_PATH=/usr/local/Server_Repo/DguWebp
APACHE_BIN_PATH=$PROJ_PATH/AkoMarket/apache8/bin


cd $APACHE_BIN_PATH
sudo -u TomcatRuntime ./shutdown.sh

