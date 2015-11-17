To stand up a NiFi distributed network:
```
# from the 'nifi' directory
docker-compose --x-networking up
```

The command will

This is a workaround until https://github.com/docker/compose/issues/2312 is implemented.

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
