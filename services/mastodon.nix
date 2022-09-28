{ pkgs, pkgsMaster, config, ... }:
{
  services.mastodon = {
    enable = true;
    package = pkgsMaster.mastodon;
    localDomain = "piperswe.me";
    extraConfig.WEB_DOMAIN = "social.piperswe.me";
    smtp.fromAddress = "noreply@piperswe.me";
    trustedProxy = "::1";
  };

  services.nginx.virtualHosts."social.piperswe.me" = {
    root = "${config.services.mastodon.package}/public/";

    locations."/system/".alias = "/var/lib/mastodon/public-system/";

    locations."/" = {
      tryFiles = "$uri @proxy";
    };

    locations."@proxy" = {
      proxyPass = "http://unix:/run/mastodon-web/web.socket";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-Proto https;
      '';
    };

    locations."/api/v1/streaming/" = {
      proxyPass = "http://unix:/run/mastodon-streaming/streaming.socket";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header X-Forwarded-Proto https;
      '';
    };
  };

  services.nginx.virtualHosts."piperswe.me" = {
    locations."/.well-known/host-meta" = {
      extraConfig = ''
        return 301 https://social.piperswe.me$request_uri;
      '';
    };
    locations."/.well-known/webfinger" = {
      extraConfig = ''
        return 301 https://social.piperswe.me$request_uri;
      '';
    };
  };

  users.groups.${config.services.mastodon.group}.members = [ config.services.nginx.user ];
}
