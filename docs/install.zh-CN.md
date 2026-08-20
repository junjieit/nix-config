# 从零安装 NixOS（junjiepc）

[English installation guide](install.md) · [项目 README](README.zh-CN.md)

本文档描述如何在一台 `x86_64` UEFI 机器上从零安装本仓库的 NixOS
配置（Hyprland + SDDM + fcitx5 + home-manager），适用于重新安装
或换到新机器的情况。

## 0. 目标磁盘布局

本仓库对应的机器有两块 NVMe 盘，分区如下：

| 设备 | 大小 | 用途 |
| --- | --- | --- |
| `/dev/nvme0n1p1` | 500M (vfat) | EFI 启动分区 `/boot` |
| `/dev/nvme0n1p2` | 2G (swap) | swap |
| `/dev/nvme0n1p3` | 剩余 (ext4) | 根分区 `/` |
| `/dev/nvme1n1p1` | 整盘 (ext4) | 数据盘 `/home/junjie/data` |

> 如果你的机器不一样，调整下面分区命令即可。最终以
> `nixos-generate-config` 生成的 `hardware-configuration.nix` 为准，
> 并提交到 `hosts/junjiepc/`。

## 1. 制作启动盘

1. 下载 NixOS minimal ISO（中科大镜像）：

   ```
   https://mirrors.ustc.edu.cn/nixos/images/nixos-unstable/nixos-minimal-x86_64-linux.iso
   ```

   同目录有 `.sha256` 校验文件，下载后执行 `sha256sum -c` 校验。

2. 确认 U 盘设备名，**不要认错盘**：

   ```sh
   lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS
   ```

3. 卸载 U 盘已有分区后，**写到整盘**（不是分区），例如 `/dev/sda`：

   ```sh
   sudo umount /dev/sda* 2>/dev/null || true
   sudo dd if=/path/to/nixos-minimal-x86_64-linux.iso of=/dev/sda bs=4M status=progress conv=fsync
   sync
   ```

   > dd 会无提示覆盖目标盘，写入前务必再次确认 `of=` 是 U 盘而非系统盘。

## 2. 启动安装器

- U 盘引导（一般是 F12 / F11 / Del 进入启动菜单）。
- 如果开启了 Secure Boot，先关闭，否则引导可能失败。
- 进入安装环境后配置网络：
  - 有线：通常自动获取即可。
  - 无线：`nmcli device wifi connect <SSID> password <密码>`，
    或使用 `iwctl`。
- 验证联网：`ping mirrors.ustc.edu.cn`。

## 3. 分区与格式化

以目标系统盘 `/dev/nvme0n1` 为例：

```sh
# 系统盘
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 501MiB
sudo parted /dev/nvme0n1 -- set 1 esp on
sudo parted /dev/nvme0n1 -- mkpart primary linux-swap 501MiB 2557MiB
sudo parted /dev/nvme0n1 -- mkpart primary ext4 2557MiB 100%

sudo mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
sudo mkswap -L swap /dev/nvme0n1p2
sudo mkfs.ext4 -L nixos /dev/nvme0n1p3

# 数据盘（可选，对应 /home/junjie/data）
sudo parted /dev/nvme1n1 -- mklabel gpt
sudo parted /dev/nvme1n1 -- mkpart primary ext4 1MiB 100%
sudo mkfs.ext4 -L data /dev/nvme1n1p1
```

> 休眠提示：swap 分区默认 2G 只够兜底。如果想启用休眠
> （suspend-to-disk），swap 需要 ≥ 内存大小（本机 31G 内存建议
> 扩到 32G，即把第二个 `mkpart` 的终点改为 `33269MiB`），否则保持
> 默认即可。

## 4. 挂载

```sh
sudo mount /dev/nvme0n1p3 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot
sudo swapon /dev/nvme0n1p2

sudo mkdir -p /mnt/home/junjie/data
sudo mount /dev/nvme1n1p1 /mnt/home/junjie/data
```

## 5. 获取本仓库配置

```sh
sudo git clone https://github.com/junjieit/nix-config.git /mnt/etc/nixos
```

如果网络不便，也可以把仓库拷贝到 U 盘再复制到 `/mnt/etc/nixos`。

## 6. 生成硬件配置

```sh
sudo nixos-generate-config --root /mnt
sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/hosts/junjiepc/
```

> 这一步会根据实际挂载生成 UUID 等硬件信息，生成后直接覆盖仓库里的
> `hosts/junjiepc/hardware-configuration.nix`，安装后记得提交。

## 7. 安装系统

```sh
cd /mnt/etc/nixos
sudo nixos-install --flake .#junjiepc
```

说明：

- flake 已内置中科大 nixpkgs 源与 `substituters`，首次安装会自动下载
  nixpkgs tarball 和二进制缓存。
- `allowUnfree = true` 已开启，`google-chrome`、`slack` 等可以直接安装。
- 如果提示 flake 不存在，确认当前目录是仓库根目录且包含 `flake.nix`。

## 8. 设置密码并重启

```sh
sudo nixos-enter --root /mnt -c 'passwd junjie'
sudo reboot
```

重启后拔出 U 盘，从系统盘引导，使用 `junjie` 登录。

## 9. 首次进入系统

- SDDM 登录后进入 Hyprland，fcitx5 拼音输入法应已可用。
- 验证配置可正常重建：

  ```sh
  cd /etc/nixos
  sudo nixos-rebuild switch --flake .#junjiepc
  ```

- 提交新生成的硬件配置：

  ```sh
  cd /etc/nixos
  git add hosts/junjiepc/hardware-configuration.nix
  git commit -m "regenerate hardware-configuration for fresh install"
  git push
  ```

> 如果想把仓库放到别处（例如 `/home/junjie/data/code/nix-config`），
> 移过去后用新路径 rebuild 即可：
> `sudo nixos-rebuild switch --flake /home/junjie/data/code/nix-config#junjiepc`。

## 常见问题

- **无线网络连不上**：`nmcli device wifi list` 查看信号，确认密码无误；
  U 盘安装环境默认使用 NetworkManager。
- **`nixos-install` 失败**：先确认 `/mnt` 挂载正确（`lsblk`、`df -h`）、
  网络可访问中科大镜像；再查看报错定位。
- **引导失败/进不了系统**：确认 BIOS 为 UEFI 模式、Secure Boot 已关闭、
  `/boot` 挂载的是 EFI 分区。
- **显卡驱动**：本机配置未包含 NVIDIA 闭源驱动；如果是 N 卡且需要
  Hyprland 硬件加速，需要额外配置 `hardware.nvidia`。
