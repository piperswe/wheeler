{ pkgs, ... }:
{
  services.elasticsearch = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9200;
    package = pkgs.elasticsearch7;
  };
}
