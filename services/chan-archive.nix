{ chan-archive, ... }:
{
  environment.systemPackages = [
    chan-archive.packages.x86_64-linux.chan-archive
  ];

  users.groups.chanarchive = {};
  users.users.chanarchive = {
    isSystemUser = true;
    group = "chanarchive";
  };

  systemd.services.chan-archive = {
    enable = true;
    unitConfig = {
      After = "postgresql.service";
    };
    serviceConfig = {
      User = "chanarchive";
      Type = "simple";
      Restart = "always";
      ExecStart = "${chan-archive.packages.x86_64-linux.chan-archive}/bin/chan-archive";
    };
    wantedBy = [ "multi-user.target" ];
    environment = {
      DATABASE_URL = "postgresql:///chanarchive?sslmode=disable&host=/var/run/postgresql";
    };
  };
}
