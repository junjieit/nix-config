{ pkgs, ... }:

let
  frontend = pkgs.writeShellApplication {
    name = "omni-code-local";
    runtimeInputs = [ pkgs.coreutils pkgs.libnotify ];
    text = builtins.readFile ./scripts/omni-code-local;
  };
  releaseBuilder = pkgs.writeShellApplication {
    name = "omni-code-build-release";
    runtimeInputs = [ pkgs.coreutils pkgs.libnotify pkgs.nix pkgs.util-linux ];
    text = builtins.readFile ./scripts/omni-code-build-release;
  };
  bridge = pkgs.writeShellApplication {
    name = "omni-code-bridge-switch";
    runtimeInputs = [ pkgs.coreutils pkgs.libnotify pkgs.systemd pkgs.util-linux ];
    text = builtins.readFile ./scripts/omni-code-bridge-switch;
  };
  bridgeBuilder = pkgs.writeShellApplication {
    name = "omni-code-bridge-build";
    runtimeInputs = [ pkgs.coreutils pkgs.libnotify pkgs.nix pkgs.util-linux pkgs.gcc pkgs.pkg-config bridge ];
    text = builtins.readFile ./scripts/omni-code-bridge-build;
  };
  desktopEntries = [
    (pkgs.makeDesktopItem {
      name = "omni-code-local";
      desktopName = "Omni Code 本地版";
      comment = "启动本地构建的 Omni Code Release 应用";
      exec = "${frontend}/bin/omni-code-local";
      icon = "/data/code/code/omni-code/web/icons/Icon-512.png";
      terminal = false;
      categories = [ "Development" ];
      keywords = [ "omni" "local" "dev" "前端" ];
    })
    (pkgs.makeDesktopItem {
      name = "omni-code-build-release";
      desktopName = "Omni Code 打包 Release";
      comment = "编译本地项目并生成 Linux Release 应用";
      exec = "${pkgs.ghostty}/bin/ghostty -e ${releaseBuilder}/bin/omni-code-build-release";
      icon = "/data/code/code/omni-code/web/icons/Icon-512.png";
      terminal = false;
      categories = [ "Development" ];
      keywords = [ "omni" "build" "release" "打包" "构建" ];
    })
    (pkgs.makeDesktopItem {
      name = "omni-code-bridge-local";
      desktopName = "Omni Code Bridge 本地版";
      comment = "编译本地 Bridge Release，成功后切换并重启服务";
      exec = "${pkgs.ghostty}/bin/ghostty -e ${bridgeBuilder}/bin/omni-code-bridge-build";
      icon = "view-refresh";
      terminal = false;
      categories = [ "Development" ];
      keywords = [ "omni" "bridge" "local" "release" "切换" ];
    })
    (pkgs.makeDesktopItem {
      name = "omni-code-bridge-restore";
      desktopName = "Omni Code Bridge 恢复原配置";
      comment = "恢复原来的 Bridge 启动配置并重启服务";
      exec = "${bridge}/bin/omni-code-bridge-switch restore";
      icon = "edit-undo";
      terminal = false;
      categories = [ "Development" ];
      keywords = [ "omni" "bridge" "restore" "恢复" ];
    })
  ];
in
{
  home.packages = [
    (pkgs.symlinkJoin {
      name = "omni-code-local-tools";
      paths = [ frontend releaseBuilder bridge bridgeBuilder ] ++ desktopEntries;
    })
  ];
}
