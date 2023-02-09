{ pkgsCloudflared, cloudflared, ... }:
{
  imports = [ cloudflared.nixosModules.cloudflared ];
  services.cloudflared-flake = {
    enable = true;
    package = pkgsCloudflared.cloudflared;
  };
  boot.kernel.sysctl."net.core.rmem_max" = 2500000;
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.ip_forward" = 1;
}
