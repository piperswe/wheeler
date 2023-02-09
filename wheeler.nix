# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nixpkgs, home-manager, piperswe-pubkeys, ... }:
{
  imports =
    [
      home-manager.nixosModules.home-manager
      piperswe-pubkeys.nixosModules.sshAuthorizedKeys
      ./hardware.nix
      ./users.nix
      ./services/loki
      ./services/avahi.nix
      ./services/borg.nix
      ./services/cloudflared.nix
      ./services/clamav.nix
      ./services/computers-computers.nix
      ./services/docker.nix
      ./services/elasticsearch.nix
      ./services/gerrit.nix
      ./services/grafana.nix
      ./services/hydra.nix
      ./services/ipfs-kubo.nix
      ./services/mastodon
      ./services/mysql.nix
      ./services/nginx.nix
      ./services/openssh.nix
      ./services/persistence-mc.nix
      ./services/plex.nix
      ./services/postfix.nix
      ./services/postgresql.nix
      ./services/prometheus.nix
      ./services/rsyslogd.nix
      ./services/samba.nix
      ./services/synapse.nix
      ./services/transmission.nix
      ./services/vaultwarden.nix
      ./services/vscode-server.nix
      # ./services/xrdp.nix
      ./services/xserver.nix
      ./services/yggdrasil.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "tank" ];

  boot.kernel.sysctl = {
    "kernel.task_delayacct" = 1;
  };

  services.zfs.autoScrub.enable = true;
  services.smartd = {
    enable = true;
    notifications = {
      test = true;
      mail.enable = true;
      mail.recipient = "contact@piperswe.me";
    };
  };
  services.sanoid = {
    enable = true;
    datasets."tank" = {
      autosnap = true;
      recursive = true;
      yearly = 5;
      monthly = 12;
      daily = 30;
      hourly = 24;
    };
  };

  networking.hostId = "273c42cb";
  networking.hostName = "wheeler";
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  networking.dhcpcd.extraConfig = "nohook resolv.conf";

  system.autoUpgrade = {
    enable = false;
    flake = github:piperswe/wheeler;
    allowReboot = true;
    rebootWindow = {
      lower = "01:00";
      upper = "08:00";
    };
  };

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.utf8";

  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = false;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;

  programs.ssh.extraConfig = ''
    Host eu.nixbuild.net
      PubkeyAcceptedKeyTypes ssh-ed25519
      IdentityFile /etc/nixbuild_id_ed25519
  '';
  programs.ssh.setXAuthLocation = true;
  services.openssh.settings.X11Forwarding = true;
  services.openssh.settings.KexAlgorithms = [
    "sntrup761x25519-sha512@openssh.com"
    "curve25519-sha256"
    "curve25519-sha256@libssh.org"
    "diffie-hellman-group-exchange-sha256"
    "diffie-hellman-group-exchange-sha1"
  ];
  services.openssh.settings.Ciphers = [
    "chacha20-poly1305@openssh.com"
    "aes256-gcm@openssh.com"
    "aes128-gcm@openssh.com"
    "aes256-ctr"
    "aes192-ctr"
    "aes128-ctr"
    "aes128-cbc"
  ];
  services.openssh.settings.Macs = [
    "hmac-sha2-512-etm@openssh.com"
    "hmac-sha2-256-etm@openssh.com"
    "umac-128-etm@openssh.com"
    "hmac-sha2-512"
    "hmac-sha2-256"
    "umac-128@openssh.com"
    "hmac-sha1"
  ];
  services.openssh.settings.HostKeyAlgorithms = "ssh-ed25519,ssh-rsa";
  services.openssh.settings.PubkeyAcceptedAlgorithms = "ssh-ed25519,ssh-rsa";

  programs.mosh.enable = true;

  programs.ssh.knownHosts = {
    nixbuild = {
      hostNames = [ "eu.nixbuild.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      extra-experimental-features = [ "nix-command" "flakes" "ca-derivations" ];
      extra-substituters = [
        "https://nix-cache.piperswe.me"
        "https://cache.ngi0.nixos.org"
        "https://cache.garnix.io"
      ];
      extra-trusted-public-keys = [
        "nix-cache.piperswe.me:4r7vyJJ/0riN8ILB+YhSCnYeynvxOeZXNsPNV4Fn8mE="
        "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
      trusted-users = [ "root" "pmc" ];
      access-tokens = "@/var/lib/nix/access-tokens";
      allowed-uris = [ "http://" "https://" ];
      max-jobs = 24;
    };
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "localhost";
        systems = [ "x86_64-linux" "i686-linux" ];
        maxJobs = 24;
        supportedFeatures = [ "benchmark" "big-parallel" "kvm" "nixos-test" ];
      }
      {
        hostName = "eu.nixbuild.net";
        systems = [ "aarch64-linux" "armv7l-linux" ];
        maxJobs = 250;
        supportedFeatures = [ "benchmark" "big-parallel" ];
      }
    ];
  };

  programs.mtr.enable = true;

  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = [ "systemd" "textfile" ];
      extraFlags = [
        "--collector.textfile.directory=/var/lib/prometheus-node-exporter-text-files"
      ];
    };
    systemd.enable = true;
  };

  system.activationScripts.node-exporter-system-version = ''
    mkdir -pm 0775 /var/lib/prometheus-node-exporter-text-files
    (
      cd /var/lib/prometheus-node-exporter-text-files
      (
        echo -n "system_version ";
        readlink /nix/var/nix/profiles/system | cut -d- -f2
      ) > system-version.prom.next
      mv system-version.prom.next system-version.prom
    )
  '';

  environment.systemPackages = [
    pkgs.libwebp
  ];

  users.groups.music-library = { };
  users.groups.video-library = { };

  services.cron.enable = true;

  virtualisation.libvirtd.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
