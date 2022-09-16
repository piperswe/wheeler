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
  boot.kernel.sysctl."net.core.rmem_max" = 2500000;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.ip_forward" = 1;
}
