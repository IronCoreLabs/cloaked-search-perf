# Perf Testing

## Local setup

First, decrypt the keys.

```bash
ironhide file decrypt cs-config/test.key.iron
```

```bash
ironhide file decrypt tsp-config/tsp.env.iron
```

Create a shared docker network:

```bash
docker network create elastic
```

Start up elastic search:

```bash
docker rm es01; docker run  --name es01 --net elastic -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e "xpack.security.enabled=false" docker.elastic.co/elasticsearch/elasticsearch:8.5.0
```

Note that this also binds to the local port 9200 in case you want to poke at the container. If you have a local ES instance you might want to remove the port bindings.

Start up TSP:

```bash
docker rm tsp-service; docker run --name tsp-service --env-file tsp-config/tsp.env --net elastic gcr.io/ironcore-images/tenant-security-proxy:4
```

Start up Cloaked Search:

```bash
 docker rm cs01; docker run --init --name cs01 -p 8675:8675 --net=elastic \
--mount type=bind,src="$(pwd)"/cs-config/config.json,target=/app/deploy.yml \
--mount type=bind,src="$(pwd)"/cs-config/indices,target=/app/indices \
--mount type=bind,src="$(pwd)"/cs-config/test.key,target=/app/test.key \
gcr.io/ironcore-images/cloaked-search:2.0.0-RC1
```


Run rally against cs01:

```bash
docker run --net elastic \
--mount type=bind,src="$(pwd)"/tracks,target=/tracks \
elastic/rally race --track-path=/tracks/so-small --test-mode --pipeline=benchmark-only --target-hosts=cs01:8675
```
