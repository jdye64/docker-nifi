# Overview

Dockerized multi-host NiFi. The following 2 deployments are provided:
- Acquisition (standalone) node talking to a NiFi Cluster Manager via RPG (site-to-site), which, in turn, manages a cluster of processing nodes
- NiFi worker nodes can be scaled up and down via a standard `docker-compose scale worker=N` command (starts with 1 node)

# Docker Networking is now GA
Docker graduated the networking to a GA status, with docker-compose updating the file format to support it as well now. It is important you upgrade to the below minimum levels or things will not work.

This also means explicitly creating an overlay network in advance is **no longer required**.

Ensure the following pre-requisites are met (due to some blocker bugs in earlier versions). As of today, the latest Docker Toolbox and Homebrew are fine.

# Pre-Requisites
- Docker 1.10+
- Docker Compose 1.6.1+
- Docker Machine 0.6.0+
- Docker Swarm 1.1+

(all downloadable as a single Docker Toolbox package as well)

The config leverages new Docker overlay networking (look Ma, no more linking!): https://github.com/docker/docker/blob/master/docs/userguide/networking/get-started-overlay.md

# Automated Environment bootstrap
Run the `bootstrap_vms.sh` in the root folder. Below commands are for educational and documentation purposes.

## Create a discovery service
Multiple implementations are now supported:
- Consul
- ZooKeeper
- Etcd

We will use Consul in this case (because I like its UI and REST API in general.)
```
docker-machine create \
                -d virtualbox \
                --virtualbox-memory 512 \
                --virtualbox-cpu-count 1 \
                --virtualbox-disk-size 512 \
                keystore

docker $(docker-machine config keystore) run -d \
    -p 8500:8500 \
    -h consul \
    --name consul \
    progrium/consul -server -bootstrap
```

## Swarm master
Change machine defaults as follows for better startup experience:
- Bump memory to 2GB
- Bump CPU cores to 2
- Reduce disk to 10GB or even less (20GB is not required for testing)

```
docker-machine create \
               -d virtualbox \
                   --virtualbox-memory 2048 \
                   --virtualbox-cpu-count 2 \
                   --virtualbox-disk-size 10240 \
               --swarm \
               --swarm-master \
               --swarm-discovery="consul://$(docker-machine ip keystore):8500" \
               --engine-opt="cluster-store=consul://$(docker-machine ip keystore):8500" \
               --engine-opt="cluster-advertise=eth1:2376" \
               host1
```

## Swarm additional node
```
docker-machine create \
              -d virtualbox \
                  --virtualbox-memory 2048 \
                  --virtualbox-cpu-count 2 \
                  --virtualbox-disk-size 10240 \
              --swarm \
              --swarm-discovery="consul://$(docker-machine ip keystore):8500" \
              --engine-opt="cluster-store=consul://$(docker-machine ip keystore):8500" \
              --engine-opt="cluster-advertise=eth1:2376" \
              host2
```

## Tell Machine to use the Swarm cluster
```
eval $(docker-machine env --swarm host1)
```

All docker commands from this point will be issued against a cluster of VMs.


# Pull images on every host

To ensure smooth operations of `docker-compose` it is recommended to cache a container image on every node:
```
cd nifi-cluster
docker-compose pull
```

# Clustered Mode
Deployment layout:
- Acquisition node
- NiFi Cluster Manager (NCM) node
- Worker node (potentially multilpe)

## Start the containers
```
cd nifi-cluster
docker-compose up
```

## Where's my UI?
If you are running `docker-compose` in a foreground, open a new terminal and execute these commands:
```
♨> eval $(docker-machine env --swarm host1)

♨> docker-compose ps
Name              Command    State                                                Ports
----------------------------------------------------------------------------------------------------------------------------------------------
nificluster_acquisition_1   ./run.sh   Up      10000/tcp, 10001/tcp, 10002/tcp, 10003/tcp, 10004/tcp, 192.168.99.104:9091->8080/tcp, 8081/tcp
nificluster_ncm_1           ./run.sh   Up      10000/tcp, 10001/tcp, 10002/tcp, 10003/tcp, 10004/tcp, 192.168.99.103:9091->8080/tcp, 8081/tcp
nificluster_worker_1        ./run.sh   Up      10000/tcp, 10001/tcp, 10002/tcp, 10003/tcp, 10004/tcp, 192.168.99.102:32770->8080/tcp, 8081/tcp
```

You are interested in the manager node `nificluster_ncm_1 - http://192.168.99.103:9091` and `nificluster_acquisition_1 - http://192.168.99.104:9091` nodes.

## Flex the Cluster
Change the number of processing nodes in a cluster (`worker` is the worker node service name from our `docker-compose.yml`):
```
♨ >  docker-compose scale worker=3
Creating and starting 2 ... done
Creating and starting 3 ... done
♨ >  docker-compose ps
          Name              Command    State                                                Ports
----------------------------------------------------------------------------------------------------------------------------------------------
nificluster_acquisition_1   ./run.sh   Up      10000/tcp, 10001/tcp, 10002/tcp, 10003/tcp, 10004/tcp, 192.168.99.104:9091->8080/tcp, 8081/tcp
nificluster_ncm_1           ./run.sh   Up      10000/tcp, 10001/tcp, 10002/tcp, 10003/tcp, 10004/tcp, 192.168.99.103:9091->8080/tcp, 8081/tcp
nificluster_worker_1        ./run.sh   Up      10000/tcp, 10001/tcp, 10002/tcp, 10003/tcp, 10004/tcp, 192.168.99.102:32770->8080/tcp, 8081/tcp
nificluster_worker_2        ./run.sh   Up      10000/tcp, 10001/tcp, 10002/tcp, 10003/tcp, 10004/tcp, 192.168.99.101:32768->8080/tcp, 8081/tcp
nificluster_worker_3        ./run.sh   Up      10000/tcp, 10001/tcp, 10002/tcp, 10003/tcp, 10004/tcp, 192.168.99.102:32771->8080/tcp, 8081/tcp
```

Now go to the NCM host and click on the `Cluster` menu item on the right. New nodes will appear shortly after registering with the
manager.

# How do I get my data in?
NiFi nodes will have no problems reaching out to an outside world for data (only governed by your host firewall).
If, however, the intent is to push data into a cluster (NiFi listens on a port), then edit a corresponding `docker-compose.yml'
file and bind your host's ports to one of the ports exposed by this docker container (10000-10004, total of 5 extra ports).

# Troubleshooting
## My `docker network ls` command hangs
Have you run `bootstrap_vms.sh` script? It instructs a user to run this command at the very end, this is critical. Unfortunately, a bash script can't export variables into a caller environment, so this command **has to be run manually**:
```
eval $(docker-machine env --swarm host1)
```
Docker network commands will work after that.
