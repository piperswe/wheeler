{ ... }:
{
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    statusPage = true;
    virtualHosts."wheeler.piperswe.me" = {
      default = true;
    };
    virtualHosts."softwarearchive.piperswe.me" = {
      root = "/tank/softwarearchive";
      locations."~ .+/$".extraConfig = ''
        add_before_body /.theme/header.html;
        add_after_body /.theme/footer.html;
        autoindex on;
        autoindex_exact_size off;
      '';
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.prometheus.exporters.nginx.enable = true;
}
