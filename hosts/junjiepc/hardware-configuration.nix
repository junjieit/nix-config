# This file was generated for the host machine junjiepc.
# If you reinstall, regenerate it with: nixos-generate-config --root /mnt
{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "ahci" "nvme" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2a376209-ac66-4b6e-a311-d75e9df41334";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/4877-3597";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  fileSystems."/home/junjie/data" =
    { device = "/dev/disk/by-uuid/0bf67370-1e6d-4c72-96d0-8c5a97a71b50";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/377184c1-49be-473a-aff5-a4ef86ec4d8e"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
