{
  inputs.nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
  inputs.nixpkgs-master.url = github:nixos/nixpkgs/master;
  inputs.nixpkgs-recoll.url = github:piperswe/nixpkgs/recoll-exiftool;
  inputs.nixpkgs-cloudflared.url = github:piperswe/nixpkgs/cloudflared-2023.3.0;
  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.deploy-rs = {
    url = github:serokell/deploy-rs;
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.utils.follows = "flake-utils";
  };
  inputs.home-manager = {
    url = github:nix-community/home-manager;
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.piperswe-pubkeys = {
    url = github:piperswe/pubkeys;
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
  };
  inputs.cloudflared.url = github:piperswe/nix-cloudflared;
  inputs.computers-computers = {
    url = github:piperswe/computers-computers;
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
  };
  inputs.glitch-soc.url = https://github.com/piperswe/glitch-soc/archive/refs/heads/add-nix.zip;
  inputs.vscode-server.url = github:msteen/nixos-vscode-server;
  inputs.nixpkgs-update.url = github:ryantm/nixpkgs-update/b9f95c67031c7de53cd3c5ea08bb68bc34a17ef3;
  inputs.devenv.url = github:cachix/devenv/v0.5;
  inputs.arion.url = github:hercules-ci/arion/da2141cd9383c8c1cdcd3364b1ba6c32058ba659;
  inputs.chan-archive = {
    url = sourcehut:~pmc/chan-archive;
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, deploy-rs, nixpkgs, nixpkgs-master, nixpkgs-recoll, nixpkgs-cloudflared, flake-utils, ... }@attrs:
    let
      systemIndependent = rec {
        nixosConfigurations.wheeler = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs // {
            pkgsMaster = import nixpkgs-master {
              system = "x86_64-linux";
              config.permittedInsecurePackages = [
                "openssl-1.1.1t"
              ];
              config.allowUnfree = true;
            };
            pkgsRecoll = nixpkgs-recoll.legacyPackages.x86_64-linux;
            pkgsCloudflared = nixpkgs-cloudflared.legacyPackages.x86_64-linux;
          };
          modules = [ ./wheeler.nix ];
        };

        deploy.nodes.wheeler = {
          hostname = "wheeler";
          sshUser = "pmc";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos nixosConfigurations.wheeler;
          };
        };
      };
      createChecks = system: {
        deploy-rs = deploy-rs.lib.${system}.deployChecks systemIndependent.deploy;
      };
      hydraJobsAttr = {
        hydraJobs = {
          wheeler = systemIndependent.nixosConfigurations.wheeler.config.system.build.toplevel;
          helloWorld = nixpkgs.legacyPackages.x86_64-linux.writeText "helloWorld" "Hello, world! This is Wheeler.";
        } // (flake-utils.lib.eachSystem [ "x86_64-linux" ] createChecks);
      };
      perSystem = flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          apps = {
            update = rec {
              type = "app";
              drv = pkgs.writeShellScript "update.sh" ''
                export PATH="${pkgs.lib.makeBinPath [ pkgs.nix ]}:$PATH"
                exec nix flake update
              '';
              program = "${drv}";
            };
            build = rec {
              type = "app";
              drv = pkgs.writeShellScript "build.sh" ''
                export PATH="${pkgs.lib.makeBinPath [ pkgs.nix pkgs.openssh ]}:$PATH"
                exec nix build '.#nixosConfigurations.wheeler.config.system.build.toplevel'
              '';
              program = "${drv}";
            };
            deploy = rec {
              type = "app";
              drv = pkgs.writeShellScript "deploy.sh" ''
                export PATH="${pkgs.lib.makeBinPath [ pkgs.nix pkgs.openssh deploy-rs.packages.${system}.default ]}:$PATH"
                exec deploy .
              '';
              program = "${drv}";
            };
            format = rec {
              type = "app";
              drv = pkgs.writeShellScript "format.sh" ''
                export PATH="${pkgs.lib.makeBinPath [ pkgs.nixpkgs-fmt ]}:$PATH"
                exec nixpkgs-fmt *.nix
              '';
              program = "${drv}";
            };
          };

          checks = flake-utils.lib.flattenTree (createChecks system);
        }
      );
    in
    systemIndependent // perSystem // hydraJobsAttr;
}
