#!/bin/sh

splash() {
  echo 'Environment:'
  echo "NIFI_UI_BANNER_TEXT=$NIFI_UI_BANNER_TEXT"
}

configure_common() {
  sed -i 's/\.\/flowfile_repository/\/flowrepo/g' $NIFI_HOME/conf/nifi.properties
  sed -i 's/\.\/content_repository/\/contentrepo/g' $NIFI_HOME/conf/nifi.properties
  sed -i 's/\.\/conf\/flow\.xml\.gz/\/flowconf\/flow.xml.gz/' $NIFI_HOME/conf/nifi.properties
  sed -i 's/\.\/conf\/archive/\/flowconf\/archive/' $NIFI_HOME/conf/nifi.properties
  sed -i 's/\.\/database_repository/\/databaserepo/g' $NIFI_HOME/conf/nifi.properties
  sed -i 's/\.\/provenance_repository/\/provenancerepo/g' $NIFI_HOME/conf/nifi.properties

  sed -i "s/nifi\.ui\.banner\.text=/nifi.ui.banner.text=${NIFI_UI_BANNER_TEXT}/g" $NIFI_HOME/conf/nifi.properties
}

configure_site2site() {
  sed -i "s/nifi\.remote\.input\.socket\.host=/nifi.remote.input.socket.host=${HOSTNAME}/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.remote\.input\.socket\.port=/nifi.remote.input.socket.port=12345/g" $NIFI_HOME/conf/nifi.properties
  # unsecure for now so we don't complicate the setup with certificates
  sed -i "s/nifi\.remote\.input\.secure=true/nifi.remote.input.secure=false/g" $NIFI_HOME/conf/nifi.properties
}

splash
configure_common

configure_site2site

# must be an exec so NiFi process replaces this script and receives signals
exec ./nifi.sh run
