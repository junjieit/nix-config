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

## 内存压力保护

主机使用容量为物理内存 50% 的 zram swap，并在应用配置时自动创建
16 GiB 的磁盘交换文件 `/var/lib/swapfile`。磁盘 swap 优先级为 0，低于 zram
默认的 5，作为额外缓冲；它会占用根分区 16 GiB 空间。使用 `swapon --show`
查看已启用的交换空间。`systemd-oomd` 监控系统服务和每个
用户管理器下的应用：用户内存压力持续超过 50%、系统服务持续超过 60%，达到
10 秒后，会选择符合条件的应用或服务进程组终止。这些百分比指内存等待压力，
不是内存使用率；被终止的应用可能丢失未保存内容。

重新构建后，使用 `oomctl` 检查监控范围，使用
`journalctl -b -u systemd-oomd` 查看终止记录。这能降低内存压力导致卡死的风险，
但不能排除显卡或其他原因造成的死机。

## 本地 Omni Code 入口

Win+D 中的 `Omni Code 打包 Release` 会打开终端，在本地项目中运行
`nix develop --no-update-lock-file --command flutter build linux --release`。
日志保存在 `~/.local/state/omni-code-build/release.log`，构建结束后按回车关闭窗口。
`Omni Code 本地版` 固定启动
`/data/code/code/omni-code/build/linux/x64/release/bundle`，不会回退到 debug 版本。

`Omni Code Bridge 本地版` 和 `Omni Code Bridge 恢复原配置` 入口保持可用。
Bridge 本地版入口会打开终端，在项目的 Nix 开发环境中执行
`cargo build --locked --release`，成功后才切换并重启服务；编译失败时保留当前服务。
启动文件为 `/data/code/code/omni-code-bridge/target/release/omni-code-bridge`。
日志保存在 `~/.local/state/omni-code-bridge-build/build.log`。

切换 bridge 会重启用户服务；失败时自动恢复之前的配置。恢复入口只移除本启动器
创建的覆盖文件，保留 `90-desktop-input.conf` 等原有覆盖配置。

也可以运行 `omni-code-build-release`、`omni-code-local`、`omni-code-bridge-build`、
`omni-code-bridge-switch local` 或
`omni-code-bridge-switch restore`。`omni-code-local --check` 显示选中的前端可执行文件。
通过 `OMNI_CODE_LOCAL_BUNDLE` 可以指定其他前端 bundle，
通过 `OMNI_CODE_BRIDGE_BINARY` 可以指定其他 bridge 可执行文件。

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
