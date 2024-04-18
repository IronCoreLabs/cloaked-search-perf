# Cloaked Search Performance Results

This directory contains runs which were executed on our Kubernetes cluster. This helps us get some consistency by being able to choose the same hardware and allocated machine specifications each time. Each run is in a path that starts with `YYYY-MM-DD` followed by a UUID that is generated for that run. These runs were runs of the [run500k](../run-500k.sh) script.

Each script execution runs the [es-rally](https://esrally.readthedocs.io/en/stable/) against both [Elastic Search](https://www.elastic.co/) and [Cloaked Search](https://ironcorelabs.com/docs/cloaked-search/). It also uses the rally tool to do the comparison of these 2 runs. This is to give an idea of the overhead of indexing using Cloaked Search. It also runs all of the queries from the [queries](../queries/) directory. These queries are run using Apache Bench against both Cloaked Search and Elastic Search and written to separate files.

Each UUID directory contains quite a few files. These fall into a few different catagories. The `TIMESTAMP` in the filenames is the timestamp of the run.

## General

- cs_version.json - The output of the Cloaked Search version endpoint. This will allow you to know what version of Cloaked Search this run was against.
- es_version.json - The output of the Elastic Search version endpoint. This will allow you to know what version of Elastic Search this run was against.

## Rally Output

- `ES-TIMESTAMP.csv` - This is the output of the es-rally tool for a connection directly to Elastic Search.
- `CS-TIMESTAMP.csv` - This is the output of the es-rally tool for a connection through Cloaked Search.
- `compare-TIMESTAMP.csv` - This is the comparison of the Elastic Search and Cloaked Search results. The time we typically pay the most attention to is `50th percentile service time`.

## Query output

- `ES-TIMESTAMP-query-QUERY_NAME.csv` - The percentile output from Apache Bench. This gives the most detail about the query timing for the running `QUERY_NAME` against Elastic Search.
- `CS-TIMESTAMP-query-QUERY_NAME.csv` - The percentile output from Apache Bench. This gives the most detail about the query timing for the running `QUERY_NAME` against Elastic Search.
- `ES-TIMESTAMP-query-QUERY_NAME.txt` - The complete output from Apache Bench. This gives the summary information about querying `QUERY_NAME` against Elastic Search.
- `CS-TIMESTAMP-query-QUERY_NAME.txt` - The complete output from Apache Bench. This gives the summary information about querying `QUERY_NAME` against Cloaked Search.
