{ pkgs, ... }:
{
  users.users.pmc = {
    isNormalUser = true;
    description = "Piper McCorkle";
    extraGroups = [ "networkmanager" "wheel" ];
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
      ];

      programs.neovim = {
        enable = true;
        plugins = with pkgs.vimPlugins; [
          vim-nix
        ];
      };

      home.stateVersion = "22.05";
    };
}
