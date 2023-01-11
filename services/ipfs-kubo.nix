{ ... }:
{
  services.kubo = {
    enable = true;
    localDiscovery = true;
    settings.Addresses.API = "/ip4/0.0.0.0/tcp/5001";
    settings.Addresses.Gateway = "/ip4/0.0.0.0/tcp/8080";
    settings.API.HTTPHeaders = {
      "Access-Control-Allow-Origin" = [
        "http://wheeler:5001"
        "http://localhost:5001"
        "http://127.0.0.1:5001"
        "https://webui.ipfs.io"
      ];
      "Access-Control-Allow-Methods" = [
        "PUT"
        "POST"
      ];
    };
  };
  networking.firewall.allowedTCPPorts = [ 4001 5001 8080 ];
  networking.firewall.allowedUDPPorts = [ 4001 ];
}
