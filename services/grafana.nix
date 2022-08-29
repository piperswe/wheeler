{ ... }:
{
  services.grafana = {
    enable = true;
    domain = "grafana.piperswe.me";
    port = 8224;
    addr = "127.0.0.1";
  };
  services.nginx.virtualHosts."grafana.piperswe.me" = {
    locations."/" = {
      proxyPass = "http://localhost:8224";
      proxyWebsockets = true;
    };
  };
}
