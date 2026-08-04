# NixOS configuration

This flake defines the `junjiepc` NixOS host for an `x86_64-linux` machine with
Hyprland.

## First installation

Boot the NixOS installer, partition and mount the target system at `/mnt`, then
generate and retain the machine-specific hardware module:

```sh
sudo nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix hosts/junjiepc/
```

Install from this checkout:

```sh
sudo nixos-install --flake .#junjiepc
```

Set the `junjie` password before rebooting with `nixos-enter --root /mnt -c 'passwd junjie'`.
After boot, rebuild with:

```sh
sudo nixos-rebuild switch --flake .#junjiepc
```

Commit `hosts/junjiepc/hardware-configuration.nix`; it is part of the
machine's declarative configuration.
