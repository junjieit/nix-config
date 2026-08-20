# Fresh NixOS installation

[中文安装指南](install.zh-CN.md) · [Project README](../README.md)

This guide describes a fresh UEFI installation of the `junjiepc` NixOS
configuration on an `x86_64` machine. Adapt device names and sizes to the
target machine and treat the generated hardware configuration as authoritative.

## 1. Boot media and network

Download a NixOS minimal ISO, verify its checksum, and write it to a USB drive.
Double-check the target device before running `dd`:

```sh
lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS
sudo umount /dev/sdX* 2>/dev/null || true
sudo dd if=/path/to/nixos-minimal-x86_64-linux.iso of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

Boot the USB in UEFI mode with Secure Boot disabled. Connect to the network
with NetworkManager, for example:

```sh
nmcli device wifi connect '<SSID>' password '<password>'
ping mirrors.ustc.edu.cn
```

## 2. Partition the system

The original machine uses a 500 MiB EFI partition, a 2 GiB swap partition, and
an ext4 root partition on `/dev/nvme0n1`. A second ext4 data disk is mounted at
`/home/junjie/data`. Replace these device names if your hardware differs.

```sh
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 501MiB
sudo parted /dev/nvme0n1 -- set 1 esp on
sudo parted /dev/nvme0n1 -- mkpart primary linux-swap 501MiB 2557MiB
sudo parted /dev/nvme0n1 -- mkpart primary ext4 2557MiB 100%

sudo mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
sudo mkswap -L swap /dev/nvme0n1p2
sudo mkfs.ext4 -L nixos /dev/nvme0n1p3
```

For hibernation, swap should be at least as large as RAM. The default 2 GiB
swap is only a small safety buffer.

## 3. Mount filesystems and fetch the repository

```sh
sudo mount /dev/nvme0n1p3 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot
sudo swapon /dev/nvme0n1p2

sudo git clone https://github.com/junjieit/nix-config.git /mnt/etc/nixos
cd /mnt/etc/nixos
```

If the data disk is available:

```sh
sudo mkdir -p /mnt/home/junjie/data
sudo mount /dev/nvme1n1p1 /mnt/home/junjie/data
```

## 4. Generate hardware configuration

```sh
sudo nixos-generate-config --root /mnt
sudo cp /mnt/etc/nixos/hardware-configuration.nix hosts/junjiepc/
```

Review the generated file before installing. It contains machine-specific UUIDs
and should be committed for that machine, but not reused elsewhere.

## 5. Install and set the password

```sh
sudo nixos-install --flake .#junjiepc
sudo nixos-enter --root /mnt -c 'passwd junjie'
sudo reboot
```

Remove the USB drive and boot from the system disk. SDDM should start the
`hyprland-uwsm` session. After logging in, rebuild once from the checkout:

```sh
cd /etc/nixos
sudo nixos-rebuild switch --flake .#junjiepc
```

## Troubleshooting

- Check mounts with `lsblk` and `df -h` if installation cannot find a filesystem.
- Ensure the firmware is in UEFI mode and Secure Boot is disabled if the system does not boot.
- Use `nmcli device wifi list` to diagnose wireless connectivity in the installer.
- For NVIDIA hardware, add an appropriate `hardware.nvidia` configuration; this host does not enable the proprietary driver by default.
- The weather module requires `WEATHERAPI_KEY`, but a missing key does not prevent the system from building.
