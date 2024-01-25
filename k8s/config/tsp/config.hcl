// This file is only here to add a few extra env vars so we don't try to talk to CB in prod.

auto_auth {
    method {
        type = "kubernetes"
        config {
            role = "cs-perf-test-tsp"
        }
    }
}
template_config {
    exit_on_retry_failure = true
}
template {
    error_on_missing_key = true
    contents = <<EOT
    {{- with secret "/secret/data/cs-perf-test/tsp/ironcore-context" -}}
SERVICE_ACCOUNT_ID={{ index .Data.data "service-account-id" }}
SERVICE_CONFIG_ID={{ index .Data.data "service-config-id" }}
SERVICE_SEGMENT_ID={{ index .Data.data "service-segment-id" }}
API_KEY={{ index .Data.data "api-key" }}
SERVICE_ENCRYPTION_PRIVATE_KEY={{ index .Data.data "service-encryption-private-key" }}
SERVICE_SIGNING_PRIVATE_KEY={{ index .Data.data "service-signing-private-key" }}
{{ end -}}
    EOT
    destination = "/vault/secrets/env"
    exec {
        command = [ "pkill", "tenant-security-proxy" ]
    }
}
