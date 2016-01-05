# Clustered Mode
Deployment layout:
- Acquisition node
- NiFi Cluster Manager (NCM) node
- Processing node (potentially multilpe)

## Create a multi-host network
```
docker network create -d overlay nifi-cluster
```

## Start the containers
```
cd nifi-cluster
docker-compose --x-networking up
```

## Where's my UI?
If you are running `docker-compose` in a foreground, open a new terminal and execute these commands:
```
♨> eval $(docker-machine env --swarm host1)

♨> docker-compose ps
       Name           Command    State                    Ports
--------------------------------------------------------------------------------
cluster-acquisition   ./run.sh   Up      192.168.99.104:9091->8080/tcp, 8081/tcp
cluster-ncm           ./run.sh   Up      192.168.99.103:9091->8080/tcp, 8081/tcp
cluster-node-1        ./run.sh   Up      192.168.99.101:9091->8080/tcp, 8081/tcp
cluster-node-2        ./run.sh   Up      192.168.99.102:9091->8080/tcp, 8081/tcp
```

You are interested in `cluster-ncm - http://192.168.99.103:9091` and `cluster-acquisition - http://192.168.99.104:9091` nodes.