{ pkgs, pkgsMaster, config, ... }:
{
  imports = [ ./module.nix ];

  services.custom-mastodon = {
    enable = true;
    package = pkgsMaster.mastodon;
    localDomain = "piperswe.me";
    extraConfig = {
      WEB_DOMAIN = "social.piperswe.me";
      S3_ENABLED = "true";
      S3_BUCKET = "mastodon";
      S3_HOSTNAME = "1c495e64ff5fd527342d7b7bf6731a1f.r2.cloudflarestorage.com";
      S3_ENDPOINT = "https://1c495e64ff5fd527342d7b7bf6731a1f.r2.cloudflarestorage.com";
      S3_PROTOCOL = "https";
      S3_ALIAS_HOST = "social-assets.piperswe.me";
      S3_PERMISSION = "private";
    };
    smtp.fromAddress = "noreply@piperswe.me";
    trustedProxy = "::1";
  };

  services.nginx.virtualHosts."social.piperswe.me" = {
    root = "${config.services.custom-mastodon.package}/public/";

    locations."/system" = {
      extraConfig = ''
        rewrite ^/system(.*) https://social-assets.piperswe.me$1 permanent;
      '';
    };

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

  users.groups.${config.services.custom-mastodon.group}.members = [ config.services.nginx.user ];
}
