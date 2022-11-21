{ ... }:
{
  services.plex = {
    enable = true;
    openFirewall = true;
  };
  users.users.plex.extraGroups = [ "music-library" "video-library" ];
}
