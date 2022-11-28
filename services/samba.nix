{ ... }:
{
  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  networking.firewall.allowedTCPPorts = [
    5357 # wsdd
  ];
  networking.firewall.allowedUDPPorts = [
    3702 # wsdd
  ];
  networking.firewall.allowPing = true;
  services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = wheeler
      netbios name = wheeler
      security = user 
      use sendfile = yes
      #max protocol = smb2
      min protocol = SMB3
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.0.0/16 127.0.0.0/8 ::1
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      home-pmc = {
        path = "/home/pmc";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "pmc";
        "force group" = "users";
        "valid users" = "pmc";
      };
      time-machine-pmc = {
        path = "/var/lib/time-machine/pmc";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "pmc";
        "force group" = "users";
        "valid users" = "pmc";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
      };
      tank = {
        path = "/tank";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "pmc";
        "force group" = "users";
        "valid users" = "pmc";
      };
      home = {
        path = "/home";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "pmc";
        "force group" = "users";
        "valid users" = "pmc";
      };
      music = {
        path = "/data/music";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "pmc";
        "force group" = "music-library";
        "valid users" = "@music-library";
      };
    };
  };
}
