# NixOS desktop configuration

[中文文档](docs/README.zh-CN.md)

This repository contains a reproducible NixOS configuration for the `junjiepc`
host on `x86_64-linux`. It uses Hyprland/Wayland as the desktop, SDDM as the
display manager, and Home Manager for user applications and dotfiles.

## Features

- Flake-based system configuration with `nixosConfigurations.junjiepc`
- Modular Hyprland Lua configuration, plus Hyprlock, Hypridle, and Wpaperd
- Wayle status bar with workspace, media, notification, weather, memory, network, audio, and power modules
- Automatic light/dark theme switching at 07:00 and 19:00 for GTK, Hyprland, Wayle, and Ghostty
- Fcitx5 Chinese input method with the Wayland frontend
- PipeWire audio, Bluetooth, NetworkManager, Docker, and XDG Desktop Portal
- Greenleaf SDDM login theme
- Neovim, Lazygit, Himalaya, Firefox, Slack, Ghostty, and other user applications

## Quick Start

Run from the repository root:

```sh
nix flake check
sudo nixos-rebuild switch --flake .#junjiepc
```

Switch the desktop theme manually:

```sh
~/.config/hypr/scripts/desktop-theme light
~/.config/hypr/scripts/desktop-theme dark
~/.config/hypr/scripts/desktop-theme toggle
```

The theme script updates GTK, Hyprland borders, Wayle colors, and open
Ghostty windows. Firefox and Slack may need to be fully restarted before they
pick up a new theme; Slack may also require toggling “Follow system” once.

The GitHub Actions runner package is installed and can be checked with
`Runner.Listener --version`. The `services.github-runners.junjiepc` entry in
`hosts/junjiepc/default.nix` remains disabled until registration is needed.
To register it later, set `url` to the repository or organization URL, set
`tokenFile` to a token file outside the repository and Nix store, and change
`enable` to `true` before rebuilding.

## Memory pressure protection

The host uses zram swap sized to 50% of RAM, plus a 16 GiB disk swap file at
`/var/lib/swapfile`, created automatically when the configuration is applied.
The disk swap has priority 0, below zram's default priority of 5. It reserves
16 GiB on the root filesystem; check active swap with `swapon --show`.
`systemd-oomd` monitors system
services and applications below each user manager. It terminates an eligible
application or service group after memory pressure stays above 50% for users
or 60% for system services for 10 seconds. These are memory stall thresholds,
not percentages of RAM used. Terminated applications can lose unsaved work.

After rebuilding, inspect coverage with `oomctl` and termination logs with
`journalctl -b -u systemd-oomd`. This reduces the risk of memory pressure
freezes; it does not diagnose GPU or other causes of lockups.

## Local Omni Code launchers

Win+D includes `Omni Code 打包 Release`, which opens a terminal to build the local
project with `nix develop --no-update-lock-file --command flutter build linux --release`.
The log is saved to `~/.local/state/omni-code-build/release.log`. Press Enter
to close the terminal after the build. `Omni Code 本地版` launches only
`/data/code/code/omni-code/build/linux/x64/release/bundle`, without a debug fallback.

`Omni Code Bridge 本地版` and `Omni Code Bridge 恢复原配置` remain available.
The local bridge entry opens a terminal, builds the release binary with
`cargo build --locked --release` in the project's Nix development shell, then switches
and restarts the service only if compilation succeeds. Logs are saved to
`~/.local/state/omni-code-bridge-build/build.log`. It uses
`/data/code/code/omni-code-bridge/target/release/omni-code-bridge`.

Switching the bridge restarts its user service. A failed switch restores the
previous configuration. Restore removes only the launcher's own drop-in and
keeps existing overrides, including `90-desktop-input.conf`.

The same actions are available as `omni-code-build-release`, `omni-code-local`,
`omni-code-bridge-build`, and
`omni-code-bridge-switch local|restore`. `omni-code-local --check` prints the
selected executable. Set `OMNI_CODE_LOCAL_BUNDLE` to select a frontend bundle or
`OMNI_CODE_BRIDGE_BINARY` to select another bridge executable.

## Repository Layout

```text
flake.nix                  Flake entry point and NixOS outputs
hosts/junjiepc/            Host-level NixOS configuration
home/junjie.nix            Home Manager configuration and user packages
home/config/hypr/          Hyprland Lua modules, scripts, and tests
home/config/wayle/         Wayle bar, themes, and runtime configuration
home/config/ghostty/       Ghostty terminal configuration
home/config/nvim/          Neovim configuration
home/config/wpaperd/       Wallpaper service configuration and assets
sddm-theme-greenleaf/      Local SDDM theme source
docs/install.md            English installation guide
docs/install.zh-CN.md      Chinese installation guide
```

`hosts/junjiepc/hardware-configuration.nix` is generated for the target
machine and should not be copied to another host. The optional
`home/config/hypr/modules/local.lua` file contains machine-specific monitor
and Bluetooth overrides and is ignored by Git.

## Fresh Installation

See [`docs/install.md`](docs/install.md) for the complete UEFI partitioning,
mounting, hardware generation, and first-boot procedure. The essential commands
are:

```sh
sudo nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix hosts/junjiepc/
sudo nixos-install --flake .#junjiepc
sudo nixos-enter --root /mnt -c 'passwd junjie'
```

After the first boot, enter the checkout and run `nixos-rebuild switch` again.

## Changes and Validation

After changing Hyprland configuration, run:

```sh
home/config/hypr/scripts/verify-config
```

For Nix or TOML changes, also run:

```sh
nix flake check && git diff --check
```

Wayle's `runtime.toml` stores runtime workspace filters; do not copy runtime
state back into the main configuration. The weather module uses
`WEATHERAPI_KEY`; without it, weather data may be unavailable but the system
can still build.

## License and Local Assets

The Greenleaf SDDM theme has its own license and resource notes in
[`sddm-theme-greenleaf/README.md`](sddm-theme-greenleaf/README.md). Wallpapers
are local assets and may need to be replaced or removed from
`home/config/wpaperd/wallpapers/` on another machine.
