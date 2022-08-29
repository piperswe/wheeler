{ ... }:
{
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    statusPage = true;
    virtualHosts."piperswe.me" = {
      root = "/var/www/piperswe.me";
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.prometheus.exporters.nginx.enable = true;
}
