{
  inputs.nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;
  inputs.nixpkgs-master.url = github:nixos/nixpkgs/master;
  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.deploy-rs = {
    url = github:serokell/deploy-rs;
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.utils.follows = "flake-utils";
  };
  inputs.home-manager = {
    # home-manager evaluation in Hydra is currently broken
    # see https://github.com/nix-community/home-manager/issues/2074#issuecomment-1230935057
    url = github:nix-community/home-manager/0434f8e4cab4f200c9b4d3741a9e5d89705e6754;
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.utils.follows = "flake-utils";
  };
  inputs.piperswe-pubkeys = {
    url = github:piperswe/pubkeys;
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
  };
  inputs.cloudflared.url = github:piperswe/nix-cloudflared;
  inputs.hydra.url = github:nixos/hydra;

  outputs = { self, deploy-rs, nixpkgs, flake-utils, ... }@attrs:
    let
      systemIndependent = rec {
        nixosConfigurations.wheeler = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs;
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
          x86_64-linux = createChecks "x86_64-linux";
          wheeler = systemIndependent.nixosConfigurations.wheeler.config.system.build.toplevel;
        };
      };
      perSystem = flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
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
