{ ... }:
{
  services.xrdp = {
    enable = true;
    openFirewall = true;
    defaultWindowManager = "xfce4-session";
  };
}
