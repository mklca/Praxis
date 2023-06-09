# SPDX-FileCopyrightText: 2023 Mikaela Allan
#
# SPDX-License-Identifier: GPL-3.0-or-later
{
  # Haumea Arguments
  self,
  super,
  root,
  # Hive/Std/Paisano Arguments
  inputs,
  cell,
  # Additional arguments added by machine cell laoder
  machineData,
  ...
}: let
  persistFilesystemOptions = [
    "relatime"
    "ssd"
    "discard=async"
    "space_cache=v2"
  ];
in {
  _imports = [
    ({config, ...}: {
      assertions = [
      ];

      fileSystems = let
        efiSysMountPoint = config.boot.loader.efi.efiSysMountPoint;
      in {
        "${efiSysMountPoint}" = {
          device = "/dev/disk/by-partlabel/andromeda-efi-partition";
          fsType = "vfat";
          options = [
            "codepage=437"
            "discard"
            "dmask=0022"
            "errors=remount-ro"
            "fmask=0133"
            "iocharset=iso8859-1"
            "noatime"
            "shortname=mixed"
          ];
        };
      };
    })
  ];

  "/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=2G"
      "mode=755"
    ];
  };

  "/etc/cryptsetup-keys.d" = {
    device = "/dev/mapper/main-persist";
    fsType = "btrfs";
    neededForBoot = true;
    options = ["ro"] ++ persistFilesystemOptions ++ ["subvol=/cryptsetup-keys"];
  };

  "/home" = {
    device = "/dev/mapper/auxlocal-home";
    fsType = "btrfs";
    options = [
      "rw"
      "noatime"
      "discard"
      "space_cache=v2"
      "subvol=/"
    ];
  };

  "/nix" = {
    device = "/dev/mapper/main-nixstore";
    fsType = "xfs";
    options = [
      "rw"
      "noatime"
      "attr2"
      "discard"
      "inode64"
      "logbufs=8"
      "logbsize=32k"
      "noquota"
    ];
  };

  "/persist/state" = {
    device = "/dev/mapper/main-persist";
    fsType = "btrfs";
    neededForBoot = true;
    options = ["rw"] ++ persistFilesystemOptions ++ ["subvol=/state"];
  };

  "/persist/ro-data" = {
    device = "/dev/mapper/main-persist";
    fsType = "btrfs";
    neededForBoot = true;
    options = ["ro"] ++ persistFilesystemOptions ++ ["subvol=/ro-data"];
  };

  "/var/log" = {
    device = "/dev/mapper/main-persist";
    fsType = "btrfs";
    options = ["rw"] ++ persistFilesystemOptions ++ ["subvol=/logs"];
  };
}
