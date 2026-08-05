{ pkgs, lib, ... }:

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
    initContent = lib.mkAfter ''
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
    '';
  };

  home.packages = with pkgs; [
    himalaya
    lazygit
    neovim
    pass
    fzf
    slack
    vim
    localsend
    codex
  ];

  xdg.enable = true;
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

  services.mpd = {
    enable = true;
    musicDirectory = "/home/junjie/Music";
  };
}
