{ config, ... }:
{
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "wheeler";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            ];
            labels = {
              exporter = "node";
            };
          }
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.postgres.port}"
            ];
            labels = {
              exporter = "postgres";
            };
          }
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.systemd.port}"
            ];
            labels = {
              exporter = "systemd";
            };
          }
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}"
            ];
            labels = {
              exporter = "nginx";
            };
          }
          {
            targets = [
              "127.0.0.1:9198" # Hydra queue runner
            ];
            labels = {
              exporter = "hydra";
            };
          }
          {
            targets = [
              "127.0.0.1:9225" # Minecraft server
            ];
            labels = {
              exporter = "minecraft";
              server_name = "persistence";
            };
          }
        ];
      }
    ];
  };
  services.nginx.virtualHosts."prometheus.piperswe.me" = {
    locations."/" = {
      proxyPass = "http://localhost:9090";
      proxyWebsockets = true;
    };
  };
}
