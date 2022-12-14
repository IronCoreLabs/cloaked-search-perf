# Perf Testing

## Local setup

First, decrypt the keys.

```bash
ironhide file decrypt cs-config/test.key.iron -o cs-config/test.key
```

```bash
ironhide file decrypt tsp-config/tsp.env.iron -o tsp-config/tsp.env
```

Start up the services:

```bash
docker compose up
```

Note that this also binds to the local port 9200 in case you want to poke at the container. If you have a local ES instance you might want to remove the port bindings.


Run rally against cs, repeat each time you want to run it:

```bash
docker compose run test-runner race --track-path=/tracks/so500k --test-mode --pipeline=benchmark-only --target-hosts=cs:8675
```

If you want to restart a service (`cs`, `es`, `tsp`, or `test-runner`):

```bash
docker compose restart [SERVICE]
```

If you make changes to the `docker-compose.yml` (for ex a new CS image) and want to load them without restarting everything:

```bash
docker compose up -d
```
