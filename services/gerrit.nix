{ ... }:
{
  services.gerrit = {
    enable = true;
    listenAddress = "127.0.0.1:8226";
    builtinPlugins = [
      "gitiles"
    ];
  };
  services.nginx.virtualHosts."gerrit.piperswe.me" = {
    locations."/" = {
      proxyPass = "http://localhost:9226";
      proxyWebsockets = true;
    };
  };
}
