{ config, pkgs, lib, llm-agents, ... }:

{
  home.username = "junjie";
  home.homeDirectory = "/home/junjie";
  home.stateVersion = "25.11";

  programs.gh.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

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
    llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.cc-switch-cli
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
    claude-code
    opencode
    pi-coding-agent
    wechat
    telegram-desktop
    flutter
    rustup
    cargo-watch
    gcc
    tree-sitter
    pkg-config
    patchelf
    libuuid
    openssl
    openssl.dev
    (python3.withPackages (pythonPackages: with pythonPackages; [ pip ]))
    imagemagick
    librsvg
    poppler-utils
    nodejs
    yarn
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
    # System TTS on Linux (Chinese voice included); fallback when spd-say absent
    espeak-ng
  ];

  xdg.enable = true;
  home.sessionVariables = {
    LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs.libuuid.lib ];
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
    "ghostty/config".source = ./config/ghostty/config;
    "hypr".source = ./config/hypr;
    "nvim".source =
      config.lib.file.mkOutOfStoreSymlink
        "/data/code/nix-config/home/config/nvim";
    "neovide".source = ./config/neovide;
    "wpaperd".source = ./config/wpaperd;
    "wayle/config.toml".source = ./config/wayle/config.toml;
    "wayle/schema.json".source = ./config/wayle/schema.json;
    "wayle/styles".source = ./config/wayle/styles;
    "wayle/themes".source = ./config/wayle/themes;
    "wayle/tombi.toml".source = ./config/wayle/tombi.toml;
    "himalaya".source = ./config/himalaya;
    "lazygit".source = ./config/lazygit;
    "mpd".source = ./config/mpd;
    "gtk-3.0".source = ./config/gtk-3.0;
    "gtk-4.0".source = ./config/gtk-4.0;
  };

  # Replace the old directory-level Home Manager link before nested links are
  # checked. Wayle needs a writable directory for its runtime configuration.
  home.activation.wayleConfigDirectory = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    wayle_dir="${config.xdg.configHome}/wayle"
    if [ -L "$wayle_dir" ]; then
      old_wayle_dir="$(readlink -f "$wayle_dir")"
      runtime_backup="$(mktemp)"
      if [ -f "$old_wayle_dir/runtime.toml" ]; then
        cp "$old_wayle_dir/runtime.toml" "$runtime_backup"
      fi
      rm "$wayle_dir"
      mkdir -p "$wayle_dir"
      if [ -s "$runtime_backup" ]; then
        install -m644 "$runtime_backup" "$wayle_dir/runtime.toml"
      fi
      rm -f "$runtime_backup"
    fi
  '';

  # Wayle persists live configuration changes here, so it must not be a
  # read-only Home Manager link.
  home.activation.wayleRuntimeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    runtime_file="${config.xdg.configHome}/wayle/runtime.toml"
    if [ ! -e "$runtime_file" ]; then
      install -Dm644 ${./config/wayle/runtime.toml} "$runtime_file"
    fi
  '';

  systemd.user.services.desktop-theme-light = {
    Unit.Description = "Apply the light desktop theme";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${config.xdg.configHome}/hypr/scripts/desktop-theme light";
    };
  };

  systemd.user.timers.desktop-theme-light = {
    Unit.Description = "Switch to the light desktop theme at 07:00";
    Timer = {
      OnCalendar = "*-*-* 07:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services.desktop-theme-dark = {
    Unit.Description = "Apply the dark desktop theme";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${config.xdg.configHome}/hypr/scripts/desktop-theme dark";
    };
  };

  systemd.user.timers.desktop-theme-dark = {
    Unit.Description = "Switch to the dark desktop theme at 19:00";
    Timer = {
      OnCalendar = "*-*-* 19:00:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  systemd.user.services.wayle-shell = {
    Unit = {
      Description = "Wayle desktop shell";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.wayle}/bin/wayle shell";
      Restart = "on-failure";
      RestartSec = 2;
    };
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

}
