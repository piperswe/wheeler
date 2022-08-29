{ ... }:
{
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    config = {
      domain = "https://vw.piperswe.me";
      rocketPort = 8222;
      websocketEnabled = true;
      websocketPort = 8223;

      useSyslog = true;
      signupsAllowed = false;
      disableAdminToken = true;
      invitationsAllowed = true;
      invitationOrgName = "Wheeler Vaultwarden";
    };
    environmentFile = "/var/lib/bitwarden_rs/environment";
  };
  services.nginx.virtualHosts."vw.piperswe.me" = {
    locations."/" = {
      proxyPass = "http://localhost:8222";
      proxyWebsockets = true;
    };
    locations."/notifications/hub" = {
      proxyPass = "http://localhost:8223";
      proxyWebsockets = true;
    };
    locations."/notifications/hub/negotiate" = {
      proxyPass = "http://localhost:8222";
      proxyWebsockets = true;
    };
  };
}
