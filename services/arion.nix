{ arion, ... }:
{
  imports = [
    arion.nixosModules.arion
  ];
  virtualisation.arion = {
    backend = "docker";
    projects = {
      "homebridge" = {
        settings.services."homebridge".service = {
          image = "oznu/homebridge:2023-01-08@sha256:ee2eef38be9cf4e564e2a0667a342b4cb371bb60f483dac1bf0b302fc78c2a62";
          restart = "always";
          network_mode = "host";
          volumes = [
            "/var/lib/homebridge:/homebridge"
          ];
        };
        settings.services."scrypted".service = {
          image = "koush/scrypted:18-bullseye-full.s6-v0.7.81";
          restart = "always";
          network_mode = "host";
          volumes = [
            "/var/lib/scrypted:/server/volume"
          ];
        };
      };
      #"roon" = {
      #  settings.services."roon".service = {
      #    image = "steefdebruijn/docker-roonserver:latest@sha256:8797f9fc214487c2af5079d5ad892ead00a10cc956a5222c4b387c6bdd2b8c66";
      #    restart = "always";
      #    network_mode = "host";
      #    environment = {
      #      TZ = "America/Chicago";
      #    };
      #    volumes = [
      #      "/var/lib/roon/app:/app"
      #      "/var/lib/roon/data:/data"
      #      "/tank/media/music/library:/music/tank"
      #      "/var/lib/roon/backup:/backup"
      #    ];
      #  };
      #};
    };
  };
  networking.firewall = {
    allowedTCPPorts = [ 8581 5353 51860 ];
    allowedUDPPorts = [ 5353 1900 51860 ];
  };
}
