# Cloaked Search Performance Results

This directory contains runs which were executed on our Kubernetes cluster. This helps us get some consistency by being able to choose the same hardware and allocated machine specifications each time. Each run is in a path that starts with `YYYY-MM-DD` followed by a UUID that is generated for that run. These runs were runs of the [run500k](../run-500k.sh) script.

Each UUID directory contains quite a few files. These fall into a few different catagories. The `TIMESTAMP` in the filenames is the timestamp of the run.

## General

- cs_version.json - The output of the Cloaked Search version endpoint. This will allow you to know what version of Cloaked Search this run was against.
- es_version.json - The output of the Elastic Search version endpoint. This will allow you to know what version of Elastic Search this run was against.

## Rally Output

- ES-TIMESTAMP.csv - This is the output of the [es-rally](https://esrally.readthedocs.io/en/stable/) tool for a connection directly to [Elastic Search](https://www.elastic.co/).
- CS-TIMESTAMP.csv - This is the output of the [es-rally](https://esrally.readthedocs.io/en/stable/) tool for a connection through [Cloaked Search](https://ironcorelabs.com/docs/cloaked-search/).

## Query output

- `ES-TIMESTAMP-query-QUERY_NAME.csv` - The percentile output from Apache Bench. This gives the most detail about the query timing for the running `QUERY_NAME` against Elastic Search.
- `CS-TIMESTAMP-query-QUERY_NAME.csv` - The percentile output from Apache Bench. This gives the most detail about the query timing for the running `QUERY_NAME` against Elastic Search.
- `ES-TIMESTAMP-query-QUERY_NAME.txt` - The complete output from Apache Bench. This gives the summary information about querying `QUERY_NAME` against Elastic Search.
- `CS-TIMESTAMP-query-QUERY_NAME.txt` - The complete output from Apache Bench. This gives the summary information about querying `QUERY_NAME` against Cloaked Search.
