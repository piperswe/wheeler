{ ... }:
{
  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    settings = {
      Peers = [
        "tcp://108.242.38.187:1337"
        "tls://108.175.10.127:61216"
        "tls://bazari.sh:3725"
        "tcp://creamy.chowder.land:9001"
        "tls://creamy.chowder.land:9002"
        "tls://creamy.chowder.land:443"
      ];
      NodeInfo = {
        name = "wheeler.piperswe.me";
        location = "Brenham, Texas";
      };
    };
  };
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;
}
