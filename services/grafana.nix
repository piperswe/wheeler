{ ... }:
{
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.piperswe.me";
      http_port = 8224;
      http_addr = "127.0.0.1";
    };
  };
  services.nginx.virtualHosts."grafana.piperswe.me" = {
    locations."/" = {
      proxyPass = "http://localhost:8224";
      proxyWebsockets = true;
    };
  };
}
