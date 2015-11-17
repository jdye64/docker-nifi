# Overview

Dockerized multi-host NiFi. The following 2 deployments are provided:
# Acquisition node talking to Processing-1 and Processing-2 nodes utilizing the site-to-site protocol
and Remote Process Groups (RPG)
# Acquisition node talking to a NiFi Cluster Manager, which, in turn, manages a cluster of processing nodes

https://github.com/docker/docker/blob/master/docs/userguide/networking/get-started-overlay.md

## swarm master
docker-machine create \
               -d virtualbox \
                   --virtualbox-memory 2048 \
                   --virtualbox-cpu-count 2 \
                   --virtualbox-disk-size 10240 \
               --swarm \
               --swarm-master \
               --swarm-discovery="consul://$(docker-machine ip mh-keystore):8500" \
               --engine-opt="cluster-store=consul://$(docker-machine ip mh-keystore):8500" \
               --engine-opt="cluster-advertise=eth1:2376" \
               host1

## swam additional node
docker-machine create \
              -d virtualbox \
                  --virtualbox-memory 2048 \
                  --virtualbox-cpu-count 2 \
                  --virtualbox-disk-size 10240 \
              --swarm \
              --swarm-discovery="consul://$(docker-machine ip mh-keystore):8500" \
              --engine-opt="cluster-store=consul://$(docker-machine ip mh-keystore):8500" \
              --engine-opt="cluster-advertise=eth1:2376" \
              host2

## create a multi-host network
docker network create -d overlay nifi

## start the cluster
docker-compose --x-networking up

# Misc
Should you need to troubleshoot issues with how Docker Compose generates and manages hostnames, here's a command one
can use to run containers manually (non-orchestrated).

docker run -itd -e "NIFI_UI_BANNER_TEXT=acquisition" --name nifi_a --net=nifi -h acquisition -p 9091:8080 aperepel/nifi
docker run -itd -e "NIFI_UI_BANNER_TEXT=processing" --name nifi_p --net=nifi -h processing -p 9091:8080 aperepel/nifi
