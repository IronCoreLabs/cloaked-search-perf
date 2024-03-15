FROM elastic/rally:2.7.1
USER root
RUN set -eux; apt-get update; apt-get install -y --no-install-recommends apache2-utils ; rm -rf /var/lib/apt/lists/*
USER 1000
ENTRYPOINT ["/entrypoint.sh"]
