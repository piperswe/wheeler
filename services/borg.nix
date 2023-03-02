{ pkgs, ... }:
{
  services.borgbackup.jobs.granite = {
    paths = [
      "/home"
      "/var/lib"
      "/tank/media/music"
      "/tank/scaningest"
      "/tank/softwarearchive"
    ];
    exclude = [
      "/tank/softwarearchive/MSDN"
    ];
    repo = "ssh://pmc@granite.piperswe.me/volume1/wheeler-borg/repo";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /root/borgbackup/passphrase";
    };
    environment.BORG_RSH = "ssh -i /root/borgbackup/ssh_key";
    compression = "auto,lzma";
    startAt = "weekly";
    preHook = ''
      /run/wrappers/bin/sudo -u postgres ${pkgs.postgresql}/bin/pg_dumpall -v -f /var/lib/postgres-backup/database.sql
      #/run/wrappers/bin/sudo -u mysql ${pkgs.mysql80}/bin/mysqldump --all-databases --verbose --result-file=/var/lib/mysql-backup/database.sql
    '';
    readWritePaths = [
      "/var/lib/postgres-backup"
      "/var/lib/mysql-backup"
    ];
  };
}
