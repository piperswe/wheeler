{ computers-computers, ... }:
{
  services.nginx.virtualHosts."piperswe.me" = {
    root = "${computers-computers.packages.x86_64-linux.website}/share/computers-computers";
    serverAliases = [
      "piperswe.me"
      "www.piperswe.me"
    ];
    extraConfig = ''
      # Expire rules for static content

      # cache.appcache, your document html and data
      location ~* \.(?:manifest|appcache|html?|xml|json)$ {
        expires -1;
      }

      # Feed
      location ~* \.(?:rss|atom|xml)$ {
        expires 1h;
        add_header Cache-Control "public";
      }

      # Media: images, icons, video, audio, HTC
      location ~* \.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp4|ogg|ogv|webm|htc)$ {
        expires 1y;
        add_header Cache-Control "public";
      }

      # CSS and Javascript
      location ~* \.(?:css|js)$ {
        expires 1M;
        add_header Cache-Control "public";
      }
    '';
  };
}
