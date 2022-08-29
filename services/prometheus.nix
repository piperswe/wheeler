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
              "127.0.0.1:${toString config.services.prometheus.exporters.postgres.port}"
              "127.0.0.1:${toString config.services.prometheus.exporters.systemd.port}"
              "127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}"
              "127.0.0.1:9198" # Hydra queue runner
            ];
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
