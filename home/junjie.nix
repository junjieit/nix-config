{ config, pkgs, lib, ... }:

let
  homeManagerProfile = "${config.xdg.stateHome}/nix/profiles/home-manager";
in
{
  home.username = "junjie";
  home.homeDirectory = "/home/junjie";
  home.stateVersion = "25.11";

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      palette = "nord";
      palettes.nord = {
        blue = "#88c0d0";
        cyan = "#8fbcbb";
        green = "#a3be8c";
        orange = "#d08770";
        red = "#bf616a";
        white = "#eceff4";
        yellow = "#ebcb8b";
      };
      directory = {
        style = "bold blue";
        fish_style_pwd_dir_length = 3;
        truncation_length = 4;
      };
      git_branch = {
        format = " [$symbol$branch]($style)";
        style = "bold cyan";
        symbol = "git:";
      };
      git_status = {
        format = " ([\$all_status$ahead_behind]($style))";
        style = "bold yellow";
      };
      cmd_duration = {
        format = " took [$duration]($style)";
        style = "bold orange";
        min_time = 2000;
      };
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };

  programs.sheldon = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      shell = "zsh";
      plugins = {
        zsh-autosuggestions = {
          github = "zsh-users/zsh-autosuggestions";
        };
        zsh-syntax-highlighting = {
          github = "zsh-users/zsh-syntax-highlighting";
        };
        zsh-completions = {
          github = "zsh-users/zsh-completions";
        };
        fzf-tab = {
          github = "Aloxaf/fzf-tab";
        };
        zsh-history-substring-search = {
          github = "zsh-users/zsh-history-substring-search";
        };
        oh-my-zsh-git = {
          github = "ohmyzsh/ohmyzsh";
          use = [ "plugins/git/git.plugin.zsh" ];
        };
        forgit = {
          github = "wfxr/forgit";
        };
      };
    };
  };

  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    initContent = lib.mkAfter ''
      bindkey -v

      # Use terminfo so history search works across terminal emulators.
      copy-buffer-to-clipboard() {
        print -rn -- "$BUFFER" | wl-copy
        zle -M 'Copied command line to Wayland clipboard'
      }
      zle -N copy-buffer-to-clipboard
      vi-yank-to-clipboard() {
        zle .vi-yank
        print -rn -- "$CUTBUFFER" | wl-copy
      }
      zle -N vi-yank-to-clipboard
      vi-yank-whole-line-to-clipboard() {
        zle .vi-yank-whole-line
        print -rn -- "$CUTBUFFER" | wl-copy
      }
      zle -N vi-yank-whole-line-to-clipboard

      bindkey -M viins '^Y' copy-buffer-to-clipboard
      bindkey -M vicmd 'y' vi-yank-to-clipboard
      bindkey -M vicmd 'Y' vi-yank-whole-line-to-clipboard

      for keymap in emacs viins; do
        bindkey -M $keymap "$terminfo[kcuu1]" history-substring-search-up
        bindkey -M $keymap "$terminfo[kcud1]" history-substring-search-down
      done

      # Keep the common xterm sequences as a fallback.
      bindkey -M emacs '^[[A' history-substring-search-up
      bindkey -M emacs '^[[B' history-substring-search-down
      bindkey -M viins '^[[A' history-substring-search-up
      bindkey -M viins '^[[B' history-substring-search-down

      # Terminals may send Backspace as DEL (^?) or Ctrl-H (^H).
      bindkey -M viins "$terminfo[kbs]" backward-delete-char
      bindkey -M viins '^?' backward-delete-char
      bindkey -M viins '^H' backward-delete-char
    '';
  };

  home.packages = with pkgs; [
    himalaya
    lazygit
    neovim
    pass
    gnupg
    pinentry-curses
    fzf
    slack
    vim
    localsend
    codex
    opencode
    pi-coding-agent
    wechat
    telegram-desktop
    flutter
    rustup
    gcc
    pkg-config
    openssl
    openssl.dev
    pnpm
    # Flutter Linux desktop build dependencies
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gtk3
    glib
    sqlite
    libsecret
    # Flutter Linux desktop build dependencies (dev outputs for pkg-config/.pc)
    gst_all_1.gstreamer.dev
    gst_all_1.gst-plugins-base.dev
    gtk3.dev
    glib.dev
    sqlite.dev
    libsecret.dev
    libunwind.dev
    orc.dev
    zlib.dev
    # flutter_soloud requires ALSA (libasound) at link time
    alsa-lib
    alsa-lib.dev
  ];

  xdg.enable = true;
  home.sessionVariables = {
    PKG_CONFIG_PATH = "${config.home.profileDirectory}/lib/pkgconfig";
    HTTP_PROXY = "http://127.0.0.1:7890";
    HTTPS_PROXY = "http://127.0.0.1:7890";
    NO_PROXY = "localhost,127.0.0.1,::1";
    http_proxy = "http://127.0.0.1:7890";
    https_proxy = "http://127.0.0.1:7890";
    no_proxy = "localhost,127.0.0.1,::1";
  };

  home.file.".ssh".source =
    config.lib.file.mkOutOfStoreSymlink "/data/.ssh";

  xdg.configFile = {
    "hypr".source = ./config/hypr;
    "nvim".source = ./config/nvim;
    "neovide".source = ./config/neovide;
    "wpaperd".source = ./config/wpaperd;
    "wayle".source = ./config/wayle;
    "himalaya".source = ./config/himalaya;
    "lazygit".source = ./config/lazygit;
    "mpd".source = ./config/mpd;
    "gtk-3.0".source = ./config/gtk-3.0;
    "gtk-4.0".source = ./config/gtk-4.0;
  };

  home.file.".local/share/applications/org.telegram.desktop.desktop".text = ''
    [Desktop Entry]
    Name=Telegram
    Comment=New era of messaging
    TryExec=Telegram
    Exec=env QT_QPA_PLATFORM=xcb HTTP_PROXY=http://127.0.0.1:7890 HTTPS_PROXY=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 NO_PROXY=localhost,127.0.0.1,::1 Telegram -- %U
    Icon=org.telegram.desktop
    Terminal=false
    StartupWMClass=TelegramDesktop
    Type=Application
    Categories=Chat;Network;InstantMessaging;Qt;
    MimeType=x-scheme-handler/tg;x-scheme-handler/tonsite;
    Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
    DBusActivatable=false
    SingleMainWindow=true
    X-GNOME-UsesNotifications=true
    X-GNOME-SingleWindow=true

    Actions=quit;

    [Desktop Action quit]
    Exec=env QT_QPA_PLATFORM=xcb HTTP_PROXY=http://127.0.0.1:7890 HTTPS_PROXY=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 https_proxy=http://127.0.0.1:7890 NO_PROXY=localhost,127.0.0.1,::1 Telegram -quit
    Name=Quit Telegram
    Icon=application-exit
  '';

  services.mpd = {
    enable = true;
    musicDirectory = "/home/junjie/Music";
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
  };

  systemd.user.services.home-manager-prune-generations = {
    Unit.Description = "Prune old Home Manager generations";
    Service = {
      Type = "oneshot";
      ExecStart =
        "${pkgs.nix}/bin/nix-env --delete-generations +10 --profile ${homeManagerProfile}";
    };
  };

  systemd.user.timers.home-manager-prune-generations = {
    Unit.Description = "Keep the 10 most recent Home Manager generations";
    Timer = {
      OnCalendar = "Sun 02:30";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
