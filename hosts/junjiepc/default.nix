{ config, lib, pkgs, ... }:

let
  androidSdk = (pkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "31" "34" "35" "36" ];
    buildToolsVersions = [ "35.0.0" "36.0.0" ];
    includeCmake = true;
    cmakeVersions = [ "3.22.1" ];
    includeEmulator = false;
    includeNDK = true;
    includeSystemImages = false;
    ndkVersions = [ "28.2.13676358" ];
  }).androidsdk;

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
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "home-manager-backup";
    users.junjie = import ../../home/junjie.nix;
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true;
  nix.settings.sandbox = false;
  imports = lib.optional (builtins.pathExists ./hardware-configuration.nix)
    ./hardware-configuration.nix;

  networking.hostName = "junjiepc";
  networking.networkmanager.enable = true;
  networking.firewall = {
    allowedTCPPorts = [ 8787 53317 ];
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
    extraGroups = [ "docker" "networkmanager" "wheel" ];
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

  fonts.packages = with pkgs; [
    maple-mono.NF-CN
  ];
  fonts.fontconfig.localConf = ''
    <match target="pattern">
      <test name="lang" compare="contains">
        <string>zh-cn</string>
      </test>
      <test name="family" compare="eq">
        <string>sans-serif</string>
      </test>
      <edit name="family" mode="prepend" binding="strong">
        <string>Noto Sans CJK SC</string>
      </edit>
    </match>
    <match target="pattern">
      <test name="lang" compare="contains">
        <string>zh-cn</string>
      </test>
      <test name="family" compare="eq">
        <string>serif</string>
      </test>
      <edit name="family" mode="prepend" binding="strong">
        <string>Noto Serif CJK SC</string>
      </edit>
    </match>
    <match target="pattern">
      <test name="lang" compare="contains">
        <string>zh-cn</string>
      </test>
      <test name="family" compare="eq">
        <string>monospace</string>
      </test>
      <edit name="family" mode="prepend" binding="strong">
        <string>Noto Sans Mono CJK SC</string>
      </edit>
    </match>
  '';

  virtualisation.docker.enable = true;

  # Docker pulls images as a system service, so it does not inherit the desktop proxy.
  systemd.services.docker.environment = {
    HTTP_PROXY = "http://127.0.0.1:7890";
    HTTPS_PROXY = "http://127.0.0.1:7890";
    ALL_PROXY = "http://127.0.0.1:7890";
    NO_PROXY = "localhost,127.0.0.1,::1";
    http_proxy = "http://127.0.0.1:7890";
    https_proxy = "http://127.0.0.1:7890";
    all_proxy = "http://127.0.0.1:7890";
    no_proxy = "localhost,127.0.0.1,::1";
  };

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
  security.sudo.extraConfig = ''
    Defaults env_keep += "HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY"
    Defaults env_keep += "http_proxy https_proxy all_proxy no_proxy"
  '';

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

  environment.sessionVariables = {
    ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
    ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
    JAVA_HOME = "${pkgs.jdk17}";
    # Keep every application on Fcitx's native Wayland input-method path.
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
    INPUT_METHOD = "fcitx";
    XMODIFIERS = "@im=fcitx";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  environment.systemPackages = with pkgs; [
    androidSdk
    jdk17
    sddmGreenleafTheme
    ghostty
    firefox
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
    docker-compose
    ripgrep
    htop
    atop
    lua
    cava
    pavucontrol
    xdg-desktop-portal-hyprland
    nix-output-monitor
    devenv
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
