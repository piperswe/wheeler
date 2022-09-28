{ pkgs, ... }:
let
  fqdn = "chat.piperswe.me";
  clientConfig = {
    "m.homeserver" = {
      base_url = "https://${fqdn}";
      server_name = "piperswe.me";
    };
    "m.identity_server".base_url = "https://vector.im";
  };
  serverConfig."m.server" = "${fqdn}:443";
  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
in
{
  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = "piperswe.me";
      listeners = [
        {
          port = 8230;
          bind_addresses = [ "::1" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [{
            names = [ "client" "federation" ];
            compress = true;
          }];
        }
      ];
      email = {
        smtp_host = "127.0.0.1";
        smtp_port = 25;
        notif_from = "noreply@piperswe.me";
      };
      experimental_features.msc3030_enabled = true;
      suppress_key_server_warning = true;
    };
    extraConfigFiles = [
      "/var/lib/matrix-synapse/shared-secret"
    ];
  };

  services.nginx.virtualHosts.${fqdn} = {
    locations."/".extraConfig = '' 
      return 404;
    '';
    locations."/_matrix".proxyPass = "http://[::1]:8230";
    locations."/_synapse/client".proxyPass = "http://[::1]:8230";
  };

  services.nginx.virtualHosts."element.piperswe.me" = {
    root = pkgs.element-web.override {
      conf = {
        default_server_config = clientConfig;
        default_country_code = "US";
        disable_custom_urls = true;
        features = {
          feature_latex_maths = true;
          feature_pinning = true;
          feature_jump_to_date = true;
          feature_bridge_state = true;
          feature_location_share_live = true;
          feature_thread = true;
        };
        brand = "chat.piperswe.me";
        permalink_prefix = "https://element.piperswe.me";
        disable_3pid_login = true;
        disable_guests = true;

      };
    };
  };

  services.nginx.virtualHosts."piperswe.me" = {
    locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
    locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
  };
}
