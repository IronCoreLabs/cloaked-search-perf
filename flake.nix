{
  description = "depot repo";
  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, flake-utils, devshell, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShell =
        let
          pkgs = import nixpkgs {
            inherit system;

            overlays = [ devshell.overlays.default ];
          };
        in
        pkgs.devshell.mkShell {
          packages = [
            (pkgs.google-cloud-sdk.withExtraComponents [ pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin ])
            pkgs.kubectl
          ];
          commands = [
            {
              name = "icl-auth";
              help = "trigger login flows for all tools that need to be logged in to";
              command = "gcloud auth login";
            }
            {
              name = "icl-load-clusters";
              help = "load kubectl clusters info expected by tools";
              command = ''
                gcloud container clusters get-credentials --project=discrete-log-1 --zone us-central1 prod1;
                gcloud container clusters get-credentials --zone us-central1-a --project=discrete-log-2 staging-cluster;
                gcloud container clusters get-credentials --region us-central1 --project=discrete-log-2 infra;
              '';
            }
            {
              name = "icl-init";
              help = "runs all commands required to set up state";
              command = ''
                icl-auth;
                icl-load-clusters;
              '';
            }
          ];
          env = [
            {
              name = "USE_GKE_GCLOUD_AUTH_PLUGIN";
              value = "True";
            }
          ];
        };
    });

}
