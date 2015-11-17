#!/bin/sh
echo "Environment:"
echo $NIFI_HOME
echo $NIFI_INSTANCE_NAME
echo `pwd`

sed -i 's/\.\/flowfile_repository/\/flowrepo/g' $NIFI_HOME/conf/nifi.properties
sed -i 's/\.\/content_repository/\/contentrepo/g' $NIFI_HOME/conf/nifi.properties
sed -i 's/\.\/conf\/flow\.xml\.gz/\/flowconf\/flow.xml.gz/' $NIFI_HOME/conf/nifi.properties
sed -i 's/\.\/conf\/archive/\/flowconf\/archive/' $NIFI_HOME/conf/nifi.properties
sed -i 's/\.\/database_repository/\/databaserepo/g' $NIFI_HOME/conf/nifi.properties
sed -i 's/\.\/provenance_repository/\/provenancerepo/g' $NIFI_HOME/conf/nifi.properties

sed -i "s/nifi\.ui\.banner\.text=/nifi.ui.banner.text=${NIFI_INSTANCE_NAME}/g" $NIFI_HOME/conf/nifi.properties

# must be an exec so NiFi process replaces this script and receives signals
exec ./nifi.sh run
