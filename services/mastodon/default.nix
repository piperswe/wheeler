{ pkgs, pkgsMaster, config, glitch-soc, ... }:
{
  imports = [ ./module.nix ];

  services.custom-mastodon = {
    enable = true;
    #package = pkgsMaster.callPackage ./glitch-soc.nix {
    #  pname = "glitch-soc";
    #  version = "4.0.2+git.${glitch-soc-rev}";
    #  srcOverride = glitch-soc;
    #  yarnSha256Override = "sha256-bSpBJBOIRsSwQioT4Ha5jPV0mEPmlUv5HZ/tV5oLenk=";
    #  dependenciesDir = ./.;
    #};
    package = glitch-soc.packages.x86_64-linux.default;
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
    elasticsearch = {
      port = 9200;
      host = "127.0.0.1";
    };
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
