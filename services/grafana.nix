{ ... }:
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        domain = "grafana.piperswe.me";
        http_port = 8224;
        http_addr = "127.0.0.1";
      };
      "auth.jwt" = {
        enabled = true;
        header_name = "Cf-Access-Jwt-Assertion";
        jwk_set_url = "https://piper.cloudflareaccess.com/cdn-cgi/access/certs";
        cache_ttl = "60m";
        username_claim = "preferred_username";
        email_claim = "email";
        expect_claims = "{ \"iss\": \"https://piper.cloudflareaccess.com\", \"aud\": \"37c5fe375c3a752789a8b445981a6019d654e6f35368cb3e112358b4533579f5\" }";
      };
    };
  };
  services.nginx.virtualHosts."grafana.piperswe.me" = {
    locations."/" = {
      proxyPass = "http://localhost:8224";
      proxyWebsockets = true;
    };
  };
}
