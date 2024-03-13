{ pkgs, ... }:
{
  services.gitea-actions-runner.package = pkgs.forgejo-actions-runner;
  services.gitea-actions-runner.instances.gitpipersweme = {
    enable = true;
    url = "https://git.piperswe.me";
    tokenFile = "/var/lib/forgejo-actions/env";
    name = "wheeler";
    hostPackages = with pkgs; [
      bash
      coreutils
      curl
      gawk
      gitMinimal
      gnused
      nodejs
      wget
      docker-client
      kubectl
    ];
    labels = [
      "self-hosted:host"
      "ubuntu-latest:docker://catthehacker/ubuntu:act-latest"
      "ubuntu-22.04:docker://catthehacker/ubuntu:act-22.04"
      "ubuntu-20.04:docker://catthehacker/ubuntu:act-20.04"
      "ubuntu-18.04:docker://catthehacker/ubuntu:act-20.04"
    ];
    settings = {
      cache = {
        enabled = true;
      };
    };
  };
}
