{ ... }:
{
  services.openssh = {
    enable = true;
    forwardX11 = true;
  };

  networking.firewall.allowedTCPPorts = [ 22 ];
}
