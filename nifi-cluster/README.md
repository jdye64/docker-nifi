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
