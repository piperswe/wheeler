{ ... }:
{
  services.transmission = {
    enable = true;
    settings.download-dir = "/tank/tmp/transmission/downloads";
    settings.rpc-bind-address = "0.0.0.0";
    settings.rpc-port = 9091;
    openFirewall = true;
  };
}
