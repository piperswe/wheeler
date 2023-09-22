{
  services.sabnzbd.enable = true;
  systemd.services.sabnzbd.serviceConfig.IOSchedulingPriority = "7";
  users.groups.media-downloads = {};
  users.users.sabnzbd.extraGroups = [ "media-downloads" ];
}
