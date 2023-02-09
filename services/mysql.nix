{ pkgs, ... }:
{
  services.mysql = {
    enable = false;
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
