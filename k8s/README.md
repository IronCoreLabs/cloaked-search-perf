# Cloaked Search Performance Test

Uses the elasticsearch rally container to do a stress test of Cloaked Search.

# Prerequisites

It needs some secrets in Vault.

1. Generate a GitHub Personal Access Token (PAT) with permission to check out the `IronCoreLabs/cloaked-search-perf` container.
1. Store it in this directory, as a `.iron` file.
1. Follow the [docs](https://github.com/IronCoreLabs/deployments/blob/main/apps/vault/base/README.md#local-vault-cli) to get access
    to Vault in staging.
1. `vault kv put /secret/cs-perf-test/cs-perf-test/env PAT=$PAT PAT_USER_NAME=$USER PAT_EMAIL=$EMAIL`, where
    - `PAT` is the PAT itself
    - `PAT_USER_NAME` is a username that will be used in the git commit message
    - `PAT_EMAIL` is the email address that will be used in the git commit message
1. `vault kv put /secret/cs-perf-test/cloaked-search/perf-test-key perf-test.key=@cs-perf-test.key`
1. `vault kv put /secret/cs-perf-test/tsp/ironcore-context service-account-id=$SERVICE_ACCOUNT_ID service-config-id=$SERVICE_CONFIG_ID service-segment-id=$SERVICE_SEGMENT_ID api-key=$API_KEY service-encryption-private-key=$SERVICE_ENCRYPTION_PRIVATE_KEY service-signing-private-key=$SERVICE_SIGNING_PRIVATE_KEY`

# Running

1. Consider updating the container image versions in `kustomization.yaml` and `cs-perf-test.yaml`.
1. Make sure your kubectl context is pointing at the staging cluster.
1. `kubectl apply -k .` in this directory to set up the namespace, PVCs, elasticsearch, and cloaked-search.
1. `kubectl create -f cs-perf-test.yaml` to create the test Job.

# Cleanup

The elasticsearch instance used by these tests is allocated quite a bit of memory and CPU. Best not to leave it running if there's
no need.

`kubectl delete ns cs-perf-test`
