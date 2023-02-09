{ ... }:
{
  services.gerrit = {
    enable = false;
    listenAddress = "127.0.0.1:8226";
    builtinPlugins = [
      "gitiles"
    ];
    serverId = "7A23E470-99F1-45D2-B02C-1ABE41A0311A";
  };
  services.nginx.virtualHosts."gerrit.piperswe.me" = {
    locations."/" = {
      proxyPass = "http://localhost:8226";
      proxyWebsockets = true;
    };
  };
}
