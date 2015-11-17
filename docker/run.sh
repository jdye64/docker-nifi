#!/bin/bash

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
  # configure the receiving end of site2site
  sed -i "s/nifi\.remote\.input\.socket\.host=/nifi.remote.input.socket.host=${HOSTNAME}/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.remote\.input\.socket\.port=/nifi.remote.input.socket.port=12345/g" $NIFI_HOME/conf/nifi.properties
  # unsecure for now so we don't complicate the setup with certificates
  sed -i "s/nifi\.remote\.input\.secure=true/nifi.remote.input.secure=false/g" $NIFI_HOME/conf/nifi.properties
}

configure_cluster_node() {
  sed -i "s/nifi\.cluster\.is\.node=false/nifi.cluster.is.node=true/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.node\.address=/nifi.cluster.node.address=${HOSTNAME}/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.node\.protocol\.port=/nifi.cluster.node.protocol.port=12346/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.node\.unicast\.manager\.address=/nifi.cluster.node.unicast.manager.address=ncm/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.node\.unicast\.manager\.protocol\.port=/nifi.cluster.node.unicast.manager.protocol.port=20001/g" $NIFI_HOME/conf/nifi.properties
}

configure_cluster_manager() {
  sed -i "s/nifi\.cluster\.is\.manager=false/nifi.cluster.is.manager=true/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.is\.manager=false/nifi.cluster.is.manager=true/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.manager\.address=/nifi.cluster.manager.address=ncm/g" $NIFI_HOME/conf/nifi.properties
  sed -i "s/nifi\.cluster\.manager\.protocol\.port=/nifi.cluster.manager.protocol.port=20001/g" $NIFI_HOME/conf/nifi.properties
}

splash
configure_common

if [ "$NIFI_INSTANCE_ROLE" == "node" ]; then
  configure_site2site
fi

if [ "$NIFI_INSTANCE_ROLE" == "cluster-node" ]; then
  configure_site2site
  configure_cluster_node
fi

if [ "$NIFI_INSTANCE_ROLE" == "cluster-manager" ]; then
  configure_site2site
  configure_cluster_manager
fi

# must be an exec so NiFi process replaces this script and receives signals
exec ./nifi.sh run
