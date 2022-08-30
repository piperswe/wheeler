{ ... }:
{
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    statusPage = true;
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.prometheus.exporters.nginx.enable = true;
}
