# NixOS 桌面配置

[English documentation](../README.md)

这是 `junjiepc` 主机的可复现 NixOS 配置，目标平台为 `x86_64-linux`。系统使用
Hyprland/Wayland 作为桌面，SDDM 负责登录，Home Manager 管理用户级应用和配置文件。

## 特性

- 使用 Flakes 管理系统配置，输出为 `nixosConfigurations.junjiepc`
- 模块化 Lua Hyprland 配置，以及 Hyprlock、Hypridle 和 Wpaperd
- Wayle 状态栏，包含工作区、媒体、通知、天气、内存、网络、音频和电源模块
- 每天 07:00/19:00 自动切换 GTK、Hyprland、Wayle 和 Ghostty 的亮暗主题
- Fcitx5 中文输入法，启用 Wayland frontend
- PipeWire 音频、蓝牙、NetworkManager、Docker 和 XDG Desktop Portal
- Greenleaf SDDM 登录主题
- Neovim、Lazygit、Himalaya、Firefox、Slack、Ghostty 等用户应用

## 快速使用

在仓库根目录执行：

```sh
nix flake check
sudo nixos-rebuild switch --flake .#junjiepc
```

手动切换桌面主题：

```sh
~/.config/hypr/scripts/desktop-theme light
~/.config/hypr/scripts/desktop-theme dark
~/.config/hypr/scripts/desktop-theme toggle
```

主题脚本会更新 GTK、Hyprland 边框、Wayle 颜色，并触发已打开 Ghostty 窗口重载。
Firefox 和 Slack 可能需要完全退出后重新打开才能读取新主题；Slack 还可能需要在
应用设置中重新切换一次“跟随系统”。

配置包含 GitHub Actions runner 软件包，系统切换后可用 `Runner.Listener --version`
检查。`hosts/junjiepc/default.nix` 中的 `services.github-runners.junjiepc` 暂时关闭；
之后注册时，将 `url` 设为仓库或组织地址，将 `tokenFile` 指向仓库和 Nix store 之外
保存的 token 文件，再将 `enable` 改为 `true` 并重新构建。

## 目录结构

```text
flake.nix                  Flake 入口和 NixOS 输出
hosts/junjiepc/            主机级 NixOS 配置
home/junjie.nix            Home Manager 配置和用户软件包
home/config/hypr/          Hyprland Lua 模块、脚本和测试
home/config/wayle/         Wayle 状态栏、主题和运行时配置
home/config/ghostty/       Ghostty 终端配置
home/config/nvim/          Neovim 配置
home/config/wpaperd/       壁纸服务配置和资源
sddm-theme-greenleaf/      本地 SDDM 主题源
docs/install.md            英文安装指南
docs/install.zh-CN.md      中文安装指南
```

`hosts/junjiepc/hardware-configuration.nix` 由目标机器生成，不应复制到其他主机。
可选的 `home/config/hypr/modules/local.lua` 用于本机显示器和蓝牙覆盖配置，默认被
Git 忽略。

## 全新安装

完整的 UEFI 分区、挂载、硬件配置生成和首次启动步骤见
[`install.zh-CN.md`](install.zh-CN.md)。核心安装命令如下：

```sh
sudo nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix hosts/junjiepc/
sudo nixos-install --flake .#junjiepc
sudo nixos-enter --root /mnt -c 'passwd junjie'
```

首次启动后进入仓库目录，再执行一次 `nixos-rebuild switch`。当
`hosts/junjiepc/hardware-configuration.nix` 存在时，主机模块会自动导入它。

## 修改与验证

修改 Hyprland 配置后运行：

```sh
home/config/hypr/scripts/verify-config
```

修改 Nix 或 TOML 后，也建议运行：

```sh
nix flake check && git diff --check
```

Wayle 的 `runtime.toml` 用于保存运行时工作区过滤设置，不要把运行时状态复制回主
配置。天气模块使用 `WEATHERAPI_KEY`；未设置时天气数据可能不可用，但不影响系统构建。

## 许可证和本地资源

Greenleaf SDDM 主题包含独立的许可证和资源说明，见
[`sddm-theme-greenleaf/README.md`](sddm-theme-greenleaf/README.md)。壁纸属于本地资源，
部署到其他机器时可能需要替换或清理 `home/config/wpaperd/wallpapers/` 中的文件。
