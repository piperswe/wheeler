{ pkgs, ... }:
{
  services.clamav = {
    daemon = {
      enable = true;
      settings = {
        VirusEvent = "${pkgs.coreutils}/bin/echo %v | ${pkgs.mailutils}/bin/mail -s 'ClamAV: Malware detected' contact@piperswe.me";
      };
    };
    updater = {
      enable = true;
    };
  };
}
