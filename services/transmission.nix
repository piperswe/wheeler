{ ... }:
{
  services.transmission = {
    enable = true;
    settings.download-dir = "/tank/tmp/transmission/downloads";
    settings.incomplete-dir-enabled = false;
    settings.rpc-bind-address = "0.0.0.0";
    settings.rpc-port = 9091;
    settings.rpc-whitelist = "127.0.0.1,192.168.0.*";
    openFirewall = true;
    openPeerPorts = true;
    openRPCPort = true;
  };
  systemd.services.transmission.serviceConfig.BindPaths = [ "/tank/softwarearchive/MSDN" ];
}
