{ pkgs, ... }:
{
  users.users.pmc = {
    isNormalUser = true;
    description = "Piper McCorkle";
    extraGroups = [ "networkmanager" "wheel" "docker" "music-library" "video-library" ];
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
            "convert"
            "fromfilename"
            "inline"
          ];
          library = "/data/music/library.db";
          directory = "/data/music/library";
          import = {
            from_scratch = true;
            detail = true;
            bell = true;
          };
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
            cautious = true;
            deinterlace = true;
          };
          convert = {
            dest = "/data/music/portable_library";
            album_art_maxwidth = 600;
            copy_album_art = true;
            format = "opus";
            formats.opus = ''
              bash -c 'mkdir -p "$(dirname "$dest")" && ${pkgs.ffmpeg_5-full}/bin/ffmpeg -i "$source" -f wav - | ${pkgs.opusTools}/bin/opusenc --bitrate 96 - "$dest"'
            '';
          };
          item_fields.disc_and_track = "u'%02i.%02i' % (disc, track) if disctotal > 1 else u'%02i' % (track)";
          paths = {
            default = "$albumartist/$album%aunique{albumartist album albumdisambig,albumtype year albumdisambig country label}%if{$albumdisambig, [%title{$albumdisambig}]}/$disc_and_track $title";
            singleton = "$albumartist/[non album tracks]/$title";
            comp = "Various Artists/$album%aunique{albumartist album albumdisambig,albumtype year albumdisambig country label}%if{$albumdisambig, [%title{$albumdisambig}]}/$disc_and_track $artist - $title";
          };
        };
      };

      home.stateVersion = "22.05";
    };
}
