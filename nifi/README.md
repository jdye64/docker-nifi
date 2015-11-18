# Non-clustered Mode
To stand up a NiFi distributed network with instances talking to each other
via a site-to-site protocol (no clustering):

## Create a multi-host network
```
docker network create -d overlay nifi
```

## Start the containers
```
cd nifi
docker-compose --x-networking up
```

Or send it to a background:
```
docker-compose --x-networking up -d
```

