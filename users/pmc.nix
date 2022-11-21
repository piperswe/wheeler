{ pkgs, ... }:
{
  users.users.pmc = {
    isNormalUser = true;
    description = "Piper McCorkle";
    extraGroups = [ "networkmanager" "wheel" "docker" "music" ];
    shell = pkgs.fish;
  };
  piperswe-pubkeys = {
    enable = true;
    user = "pmc";
  };
  home-manager.users.pmc = { config, pkgs, ... }:
    {
      home.username = "pmc";
      home.homeDirectory = "/home/pmc";

      programs.fish.enable = true;

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      home.packages = with pkgs; [
        nodejs-16_x
        nixpkgs-fmt
        cloudflared
        htop
        neofetch
        docker-compose
      ];

      programs.neovim = {
        enable = true;
        plugins = with pkgs.vimPlugins; [
          vim-nix
        ];
      };

      programs.git = {
        enable = true;
        userName = "Piper McCorkle";
        userEmail = "contact@piperswe.me";
      };

      programs.beets = {
        enable = true;
        settings = {
          plugins = [
            "chroma"
            "embedart"
            "fetchart"
            "mbsync"
            "replaygain"
            "mbsubmit"
          ];
          library = "/data/music/library.db";
          directory = "/data/music/library";
          match.preferred = {
            countries = [ "US" ];
            original_year = true;
          };
          embedart = {
            maxwidth = 1024;
            quality = 75;
          };
          fetchart = {
            sources = [
              "filesystem"
              "coverart"
            ];
            high_resolution = true;
          };
        };
      };

      home.stateVersion = "22.05";
    };
}
