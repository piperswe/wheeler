{ pkgs, ... }:
{
  services.mysql = {
    enable = true;
    package = pkgs.mysql80;
    ensureDatabases = [ "persistencemcprism" ];
    ensureUsers = [
      {
        name = "persistencemcprism";
        ensurePermissions = {
          "persistencemcprism.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };
}
