{ pkgsMaster, ... }:
{
  services.plex = {
    enable = true;
    openFirewall = true;
    package = pkgsMaster.plex;
  };
  services.nginx.virtualHosts."plex.piperswe.me" = {
    locations."/" = {
      proxyPass = "http://localhost:32400";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $http_x_real_ip;
        proxy_set_header X-Forwarded_for $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto;
        proxy_set_header Sec-WebSocket-Extensions $http_sec_websocket_extensions;
        proxy_set_header Sec-WebSocket-Key $http_sec_websocket_key;
        proxy_set_header Sec-WebSocket-Version $http_sec_websocket_version;
        proxy_redirect off;
        proxy_buffering off;
      '';
    };
  };
  users.users.plex.extraGroups = [ "music-library" "video-library" ];
}
