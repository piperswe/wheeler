{
  services.radarr.enable = true;
  systemd.services.radarr.serviceConfig.IOSchedulingPriority = "7";
  users.users.radarr.extraGroups = [ "media-downloads" "video-library" ];
}
