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
    };
  };
  networking.firewall = {
    allowedTCPPorts = [ 8581 5353 51860 ];
    allowedUDPPorts = [ 5353 1900 51860 ];
  };
}
