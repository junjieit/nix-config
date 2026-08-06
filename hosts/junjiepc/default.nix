{ config, lib, pkgs, home-manager, ... }:

let
  sddmGreenleafTheme = pkgs.stdenvNoCC.mkDerivation {
    pname = "sddm-theme-greenleaf";
    version = "1.1";
    src = ../../sddm-theme-greenleaf;
    installPhase = ''
      mkdir -p "$out/share/sddm/themes/greenleaf"
      cp -r ./* "$out/share/sddm/themes/greenleaf/"
    '';
  };
in

{
  nixpkgs.config.allowUnfree = true;
  nix.settings.sandbox = false;
  imports = lib.optional (builtins.pathExists ./hardware-configuration.nix)
    ./hardware-configuration.nix;

  networking.hostName = "junjiepc";
  networking.networkmanager.enable = true;
  networking.firewall = {
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.bluetooth.enable = true;
  services.udisks2.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
        fcitx5-gtk
        qt6Packages.fcitx5-qt
      ];
      settings.inputMethod = {
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us";
          DefaultIM = "pinyin";
        };
        "Groups/0/Items/0" = {
          Name = "keyboard-us";
          Layout = "";
        };
        "Groups/0/Items/1" = {
          Name = "pinyin";
          Layout = "";
        };
        GroupOrder."0" = "Default";
      };
    };
  };

  console.keyMap = "us";
  services.xserver.xkb.layout = "us";

  users.users.junjie = {
    isNormalUser = true;
    description = "junjie";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  nixpkgs.overlays = [
    (final: prev: {
      hyprland = prev.hyprland.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ final.git ];
      });
    })
  ];

  programs.zsh.enable = true;
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.dconf.enable = true;

  services.displayManager = {
    enable = true;
    defaultSession = "hyprland-uwsm";
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "greenleaf";
      extraPackages = [
        pkgs.kdePackages.qt5compat
        pkgs.kdePackages.qtvirtualkeyboard
      ];
      settings.General = {
        Numlock = "on";
      };
    };
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;
  security.pam.services.hyprlock = { };

  hardware.graphics.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  environment.systemPackages = with pkgs; [
    home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
    sddmGreenleafTheme
    ghostty
    google-chrome
    kdePackages.dolphin
    rofi
    hyprlock
    hypridle
    wpaperd
    wayle
    clash-verge-rev
    synology-drive-client
    neovide
    keepassxc
    grim
    slurp
    swappy
    cliphist
    wl-clipboard
    brightnessctl
    jq
    mpc
    mpd
    udiskie
    lxqt.lxqt-policykit
    pass
    git
    ripgrep
    lua
    cava
    pavucontrol
    xdg-desktop-portal-hyprland
    nix-output-monitor
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  # Pass the desktop proxy to builds executed by nix-daemon.
  systemd.services.nix-daemon.environment = {
    HTTP_PROXY = "http://127.0.0.1:7890";
    HTTPS_PROXY = "http://127.0.0.1:7890";
    ALL_PROXY = "http://127.0.0.1:7890";
    NO_PROXY = "localhost,127.0.0.1,::1";
  };

  nix.gc = {
    automatic = true;
    dates = "Sun 03:00";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "25.11";
}
