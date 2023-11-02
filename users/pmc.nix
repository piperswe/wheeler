{ pkgs, nixpkgs-update, pkgsRecoll, devenv, ... }:
{
  users.users.pmc = {
    isNormalUser = true;
    description = "Piper McCorkle";
    extraGroups = [ "networkmanager" "wheel" "docker" "music-library" "video-library" "mastodon" "libvirtd" "scanner" "softwarearchive" "media-downloads" ];
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
        EDITOR = "hx";
        VISUAL = "hx";
        CHROME_BINARY = "${pkgs.google-chrome}/bin/google-chrome-stable";
        YOUTUBEDL_BINARY = "${pkgs.yt-dlp}/bin/yt-dlp";
      };

      home.packages = [
        pkgs.nodejs-18_x
        pkgs.nixpkgs-fmt
        pkgs.cloudflared
        pkgs.htop
        pkgs.neofetch
        pkgs.docker-compose
        # pkgs.awscli2
        pkgs.iotop
        pkgs.screen
        pkgs.virt-manager
        pkgs.file
        pkgs.wget
        pkgs.ghostscript
        pkgs.unrtf
        pkgs.evince
        pkgs.google-chrome
        (pkgs.writeScriptBin "google-chrome" "exec ${pkgs.google-chrome}/bin/google-chrome-stable \"$@\"")
        pkgs.ripgrep
        pkgsRecoll.recoll
        nixpkgs-update.packages.x86_64-linux.nixpkgs-update
        devenv.packages.x86_64-linux.devenv
      ];

      programs.neovim = {
        enable = true;
        plugins = with pkgs.vimPlugins; [
          vim-nix
        ];
      };

      programs.helix = {
        enable = true;
        settings = {
          editor.true-color = true;
          theme = "boo_berry";
        };
      };

      programs.git = {
        enable = true;
        userName = "Piper McCorkle";
        userEmail = "contact@piperswe.me";
      };

      programs.beets = {
        enable = true;
        settings = {
          include = [
            "/home/pmc/beetsauth.yml"
          ];
          plugins = [
            "chroma"
            "embedart"
            "fetchart"
            "mbsync"
            "mbcollection"
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
          mbcollection = {
            auto = true;
            collection = "7a8bdef2-e937-42ac-b883-43b739b32798";
            remove = true;
          };
        };
      };

      programs.direnv.enable = true;

      programs.mbsync = {
        enable = true;
        extraConfig = ''
          IMAPAccount fastmail
          Host imap.fastmail.com
          User contact@piperswe.me
          PassCmd "${pkgs.coreutils}/bin/cat ~/.fastmail_password"
          SSLType IMAPS

          IMAPStore fastmail-remote
          Account fastmail

          MaildirStore fastmail-local
          SubFolders Verbatim
          Path ~/.mail/fastmail/
          Inbox ~/.mail/fastmail/Inbox

          Channel fastmail
          Far :fastmail-remote:
          Near :fastmail-local:
          Patterns *
          Create Near
          Remove None
          Expunge None
          SyncState *
        '';
      };
      services.mbsync = {
        enable = true;
        frequency = "5m";
        postExec = "${pkgs.notmuch}/bin/notmuch new";
      };

      programs.notmuch = {
        enable = true;
        extraConfig = {
          database.path = "/home/pmc/.mail/fastmail";
          user.name = "Piper McCorkle";
          user.primary_email = "contact@piperswe.me";
        };
      };

      home.stateVersion = "22.05";
    };
}
