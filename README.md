# Overview

Dockerized multi-host NiFi. The following 2 deployments are provided:
- Acquisition node talking to Processing-1 and Processing-2 nodes utilizing the site-to-site protocol
and Remote Process Groups (RPG)
- Acquisition node talking to a NiFi Cluster Manager via RPG, which, in turn, manages a cluster of processing nodes

# Pre-Requisites
- Docker 1.9+
- Docker Compose 1.5+
- Docker Machine 0.5.0+
- Docker Swarm 1.0+

(all downloadable as a single Docker Toolbox package as well)

The config leverages new Docker overlay networking (look Ma, no more linking!): https://github.com/docker/docker/blob/master/docs/userguide/networking/get-started-overlay.md

## Note on NiFi release
The `Dockerfile` currently leverages a dev snapshot of NiFi 0.4.0, just put a tar.gz
of the distro into `nifi` folder. This will be updated once 0.4.0 is out and propagates
to public repositories.

Also, the Compose configuration wil be updated to use a public image from Docker Hub after
an official NiFi release.

# Automated Environment bootstrap
Run the `bootstrap_vms.sh` in the root folder. Below commands are for educational and documentation purposes.

## Create a discovery service
Multiple implementations are now supported:
- Consul
- ZooKeeper
- Etcd

We will use Consul in this case (because I like it's UI and REST API in general.)
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

# Troubleshooting
When startup complains about not being able to allocate port 9091 on any nodes, try the following:
```
docker-compose stop
docker-compose rm -f
docker ps -a
# look for any containers related to NiFi
docker rm <containerId>
docker-compose --x-networking up
```

The port binding will ensure only 1 instance is bound per node/vm. One can edit the `docker-compose.yml`
file to change binding ports for processing nodes, as an alternative.

Of course, when running in a cluster, this won't be an issue, as the web ui port need not
be even exposed (nodes will deny access and send the user to the NiFi Cluster Manager instance instead.)

Should you need to troubleshoot issues with how Docker Compose generates and manages hostnames, here's a command one
can use to run containers manually (non-orchestrated).

```
docker run -itd -e "NIFI_UI_BANNER_TEXT=acquisition" --name nifi_a --net=nifi -h acquisition -p 9091:8080 aperepel/nifi
docker run -itd -e "NIFI_UI_BANNER_TEXT=processing" --name nifi_p --net=nifi -h processing -p 9091:8080 aperepel/nifi
```
