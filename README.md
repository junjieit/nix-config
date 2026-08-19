# NixOS desktop configuration

这是 `junjiepc` 的可复现 NixOS 配置，目标平台为 `x86_64-linux`。系统使用
Hyprland/Wayland 作为桌面，SDDM 负责登录，Home Manager 管理用户级应用和配置。

## 特性

- Flakes 管理系统构建和依赖，使用 `nixosConfigurations.junjiepc`
- Hyprland（Lua 模块化配置）、Hyprlock、Hypridle 和 Wpaperd
- Wayle 状态栏与下拉面板，包含工作区、媒体、通知、天气、内存、网络、音频和电源模块
- 每天 07:00/19:00 自动切换亮暗桌面主题，并同步 GTK、Hyprland、Wayle 和 Ghostty
- Fcitx5 中文输入法（Wayland frontend）
- PipeWire 音频、蓝牙、NetworkManager、Docker 和 XDG Desktop Portal
- SDDM Greenleaf 登录主题
- Neovim、Lazygit、Himalaya、Firefox、Slack、Ghostty 等用户环境

## 快速使用

在仓库根目录执行：

```sh
# 查看配置（不切换系统）
nix flake check

# 应用系统和 Home Manager 配置
sudo nixos-rebuild switch --flake .#junjiepc
```

切换主题：

```sh
~/.config/hypr/scripts/desktop-theme light
~/.config/hypr/scripts/desktop-theme dark
~/.config/hypr/scripts/desktop-theme toggle
```

主题脚本会更新 GTK 的 `color-scheme`/`gtk-theme`、Hyprland 活动边框、Wayle
调色板，并重启 Wayle shell。Firefox 和 Slack 等应用通常需要完全退出后重新打开
才会读取新的主题；Slack 还可能需要在应用设置中重新切换一次“跟随系统”。

## 目录结构

```text
flake.nix                  flake 入口和 nixosConfigurations
hosts/junjiepc/            主机级 NixOS 配置
home/junjie.nix            Home Manager 用户配置和软件包
home/config/hypr/          Hyprland Lua 配置、脚本和测试
home/config/wayle/         状态栏配置、主题和运行时配置
home/config/ghostty/       Ghostty 终端配置
home/config/nvim/          Neovim 配置
home/config/wpaperd/       壁纸服务配置和壁纸资源
sddm-theme-greenleaf/      本地 SDDM 主题源
docs/install.md            从零安装指南
```

`hosts/junjiepc/hardware-configuration.nix` 由目标机器生成，不应手工复制到
其他机器。Hyprland 的 `home/config/hypr/modules/local.lua` 是可选的本机显示器和
蓝牙覆盖配置，默认不纳入 Git。

## 首次安装

完整的 UEFI 分区、挂载、硬件配置生成和首次启动步骤见
[`docs/install.md`](docs/install.md)。最小流程如下：

```sh
sudo nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix hosts/junjiepc/
sudo nixos-install --flake .#junjiepc
sudo nixos-enter --root /mnt -c 'passwd junjie'
```

首次启动后进入仓库目录，再执行一次 `nixos-rebuild switch`。如果硬件配置不在
默认路径，可以先将它放入 `hosts/junjiepc/hardware-configuration.nix`；该文件存在
时会由主机模块自动导入。

## 修改与验证

修改 Hyprland 配置后运行：

```sh
home/config/hypr/scripts/verify-config
```

它会检查 Lua/Hyprland 配置并运行 workspace group 测试。修改 Nix 或 TOML 后建议
分别运行：

```sh
nix flake check
git diff --check
```

Wayle 的 `runtime.toml` 用于保存运行时生成的工作区过滤设置；不要把运行时状态
手工复制回主配置。天气模块使用 `WEATHERAPI_KEY`，未设置该变量时天气模块可能
无法获取数据，但不会影响系统构建。

## 许可证和本地资源

仓库中的 Greenleaf SDDM 主题包含独立的许可证和资源说明，见
[`sddm-theme-greenleaf/README.md`](sddm-theme-greenleaf/README.md)。壁纸属于本地
资源，不保证在其他机器上存在；部署到新机器时请替换或清理
`home/config/wpaperd/wallpapers/` 中的文件。
