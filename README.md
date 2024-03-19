# Cloaked Search Performance Testing

This repository is a way to do some basic performance testing of Cloaked Search. This tests the indexing using [rally](https://esrally.readthedocs.io/en/stable/) and query tests using apache bench. We have some [results](./results/) committed and ways to run them locally and in our k8s cluster.

Note that results will vary wildly depending on your os, cpu, memory, etc. We're only really looking for if the results are wildly different when running them in k8s since we more tightly control the resources there.

## Building docker container

The Dockerfile in this repo is a thin wrapper around the esrally one that just adds Apache Bench to the container. In order to build it I did the following:

```bash
docker build . -t ironcorelabs/rally:2.7.1
```

The version of the container should change if the Dockerfile has a different version of the rally tool inside of it.

If you're building a new version for testing using k8s, you then want to tag and push it to our private repository. For local testing this isn't required.

```bash
docker tag docker.io/ironcorelabs/rally:2.7.1  gcr.io/ironcore-dev-1/rally:2.7.1
docker push gcr.io/ironcore-dev-1/rally:2.7.1
```

## Local testing

Start up the services and run the test:

```bash
docker compose up
```

Note that this also binds to the local port 9200 in case you want to poke at the container. If you have a local ES instance you might want to remove the port bindings.

The results will be in `rally-home/cloaked-search-perf/results`.

If you want to run them again you can:

```bash
docker compose restart test-runner
```

If you make changes to the `docker-compose.yml` (for ex a new CS image) and want to load them without restarting everything:

```bash
docker compose up -d
```
