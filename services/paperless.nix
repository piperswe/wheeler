{ config, lib, ... }:
{
  services.paperless = {
    enable = true;
    consumptionDir = "/tank/scaningest";
    consumptionDirIsPublic = true;
    extraConfig = {
      PAPERLESS_URL = "https://paperless.piperswe.me";
      # Secured behind Access so this is fine
      PAPERLESS_AUTO_LOGIN_USERNAME = "pmc";
      PAPERLESS_TIME_ZONE = "America/Chicago";
      PAPERLESS_NLTK_DIR = "/var/lib/paperless/nltk_data";
    };
  };
  services.nginx.virtualHosts."paperless.piperswe.me" = {
    locations."/" = {
      proxyPass = "http://localhost:${builtins.toString config.services.paperless.port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_redirect off;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Host $server_name;
        add_header P3P 'CP=""';
      '';
    };
  };
}
