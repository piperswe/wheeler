{ nixpkgs-master, cloudflared, ... }:
let
  pkgsMaster = nixpkgs-master.legacyPackages.x86_64-linux;
in
{
  imports = [ cloudflared.nixosModules.cloudflared ];
  services.cloudflared = {
    enable = true;
    package = pkgsMaster.cloudflared;
  };
}
