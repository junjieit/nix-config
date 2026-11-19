{
  coreutils,
  makeDesktopItem,
  symlinkJoin,
  wineWow64Packages,
  wqy_microhei,
  writeShellApplication,
  writeText,
}:

let
  fontMappings = writeText "wechat-devtools-wine-fonts.reg" ''
    Windows Registry Editor Version 5.00

    [HKEY_CURRENT_USER\Control Panel\Desktop]
    "FontSmoothing"="2"
    "FontSmoothingType"=dword:00000002
    "FontSmoothingOrientation"=dword:00000001
    "FontSmoothingGamma"=dword:00000578

    [HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\FontSubstitutes]
    "MS Shell Dlg"="WenQuanYi Micro Hei"
    "MS Shell Dlg 2"="WenQuanYi Micro Hei"
    "MS Sans Serif"=-
    "Microsoft Sans Serif"=-
    "Tahoma"=-
    "SimSun"="WenQuanYi Micro Hei"
    "NSimSun"="WenQuanYi Micro Hei"
    "Microsoft YaHei"="WenQuanYi Micro Hei"
    "Microsoft YaHei UI"="WenQuanYi Micro Hei"

    [HKEY_CURRENT_USER\Software\Wine\Fonts\Replacements]
    "SimSun"="WenQuanYi Micro Hei"
    "NSimSun"="WenQuanYi Micro Hei"
    "Microsoft YaHei"="WenQuanYi Micro Hei"
    "Microsoft YaHei UI"="WenQuanYi Micro Hei"
  '';
  launcher = writeShellApplication {
    name = "wechat-devtools-wine";
    runtimeInputs = [ coreutils wineWow64Packages.staging ];
    text = ''
      export WINEPREFIX="''${WECHAT_DEVTOOLS_WINEPREFIX:-$HOME/.local/share/wineprefixes/wechat-devtools}"
      export WINEARCH=win64
      export WINEDEBUG="''${WINEDEBUG:--all}"
      export WINEDLLOVERRIDES="winemenubuilder.exe=d''${WINEDLLOVERRIDES:+;$WINEDLLOVERRIDES}"
      # Wine resets locale-dependent font links when the ANSI code page changes.
      # Keep registry setup and the application in the same Chinese locale.
      export LANG=zh_CN.UTF-8
      export LC_ALL=zh_CN.UTF-8

      app_dir="$WINEPREFIX/drive_c/WeChatDevTools"
      if [ ! -f "$app_dir/微信开发者工具.exe" ]; then
        printf 'WeChat DevTools is not installed in %s\n' "$app_dir" >&2
        exit 1
      fi

      # Wine's native file dialogs need a CJK font and Windows font aliases.
      fonts_dir="$WINEPREFIX/drive_c/windows/Fonts"
      mkdir -p "$fonts_dir"
      ln -sfn ${wqy_microhei}/share/fonts/truetype/wqy-microhei.ttc "$fonts_dir/wqy-microhei.ttc"
      wine regedit /S ${fontMappings}

      # Existing Latin fonts win over FontSubstitutes in Wine. Substituting
      # them also suppresses their SystemLink entries, so link missing glyphs
      # to the CJK font instead and keep the standard Windows fallbacks.
      font_link_key='HKLM\Software\Microsoft\Windows NT\CurrentVersion\FontLink\SystemLink'
      font_links='wqy-microhei.ttc,WenQuanYi Micro Hei;SIMSUN.TTC,SimSun;MINGLIU.TTC,PMingLiU;MSGOTHIC.TTC,MS UI Gothic;BATANG.TTC,Batang;MSYH.TTC,Microsoft YaHei UI;MSJH.TTC,Microsoft JhengHei UI;YUGOTHM.TTC,Yu Gothic UI;MALGUN.TTF,Malgun Gothic;SEGUISYM.TTF,Segoe UI Symbol'
      for font in Tahoma 'Microsoft Sans Serif' 'MS Sans Serif' Arial 'Segoe UI' 'Lucida Sans Unicode'; do
        wine reg add "$font_link_key" /v "$font" /t REG_MULTI_SZ /s ';' /d "$font_links" /f >/dev/null
      done

      cd "$app_dir"
      # Chromium's GPU process crashes under Wine on this host.
      exec wine "$app_dir/微信开发者工具.exe" --disable-gpu --lang=zh-CN "$@"
    '';
  };
  desktopItem = makeDesktopItem {
    name = "wechat-devtools-wine";
    desktopName = "微信开发者工具 (Wine)";
    comment = "微信小程序开发者工具，使用独立 Wine 环境";
    exec = "${launcher}/bin/wechat-devtools-wine";
    icon = "applications-development";
    terminal = false;
    categories = [ "Development" "IDE" ];
    startupWMClass = "微信开发者工具.exe";
  };
in
symlinkJoin {
  name = "wechat-devtools-wine";
  paths = [ launcher desktopItem ];
  meta.mainProgram = "wechat-devtools-wine";
}
