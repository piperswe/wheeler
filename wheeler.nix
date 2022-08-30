# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, home-manager, piperswe-pubkeys, ... }:
{
  imports =
    [
      home-manager.nixosModules.home-manager
      piperswe-pubkeys.nixosModules.sshAuthorizedKeys
      ./hardware.nix
      ./users.nix
      ./services/loki
      ./services/cloudflared.nix
      ./services/docker.nix
      ./services/gerrit.nix
      ./services/grafana.nix
      ./services/hydra.nix
      ./services/nginx.nix
      ./services/openssh.nix
      ./services/postgresql.nix
      ./services/prometheus.nix
      ./services/rsyslogd.nix
      ./services/vaultwarden.nix
      ./services/xrdp.nix
      ./services/xserver.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "wheeler";
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  networking.dhcpcd.extraConfig = "nohook resolv.conf";

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

  programs.ssh.extraConfig = ''
    Host eu.nixbuild.net
      PubkeyAcceptedKeyTypes ssh-ed25519
      IdentityFile /etc/nixbuild_id_ed25519
  '';

  programs.ssh.knownHosts = {
    nixbuild = {
      hostNames = [ "eu.nixbuild.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      extra-experimental-features = [ "nix-command" "flakes" ];
      extra-substituters = [
        "https://nix-cache.piperswe.me"
      ];
      extra-trusted-public-keys = [
        "nix-cache.piperswe.me:4r7vyJJ/0riN8ILB+YhSCnYeynvxOeZXNsPNV4Fn8mE="
      ];
      trusted-users = [ "root" "pmc" ];
      access-tokens = "@/var/lib/nix/access-tokens";
      allowed-uris = [ "http://" "https://" ];
    };
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "eu.nixbuild.net";
        systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux" ];
        maxJobs = 250;
        supportedFeatures = [ "benchmark" "big-parallel" ];
      }
    ];
  };

  programs.mtr.enable = true;

  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = [ "systemd" ];
    };
    systemd.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
