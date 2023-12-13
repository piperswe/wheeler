{
  services.sonarr.enable = true;
  systemd.services.sonarr.serviceConfig.IOSchedulingPriority = "7";
  users.users.sonarr.extraGroups = [ "media-downloads" "video-library" ];
}
