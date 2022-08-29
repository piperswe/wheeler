{ pkgs, lib, ... }:
{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = lib.mkOverride 10 ''
      local all all ident
      host all all 127.0.0.1/32 md5
      host all all ::1/128 md5
      host all all 192.168.100.0/24 md5
    '';
    initialScript = pkgs.writeText "postgres-init.sql" ''
      CREATE USER pmc SUPERUSER;
      CREATE DATABASE pmc OWNER pmc;

      CREATE USER vaultwarden;
      CREATE DATABASE vaultwarden OWNER vaultwarden;
    '';
  };
  services.prometheus.exporters.postgres = {
    enable = true;
    runAsLocalSuperUser = true;
  };
}
