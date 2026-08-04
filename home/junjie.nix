{ pkgs, ... }:

{
  home.username = "junjie";
  home.homeDirectory = "/home/junjie";
  home.stateVersion = "25.11";

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.sheldon = {
    enable = true;
    settings = {
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
        forgit = {
          github = "wfxr/forgit";
        };
      };
    };
  };

  home.packages = with pkgs; [
    himalaya
    lazygit
    neovim
    pass
    fzf
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
