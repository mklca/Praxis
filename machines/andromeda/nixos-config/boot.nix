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
}: {
  _imports = [
    ({pkgs, ...}: {
      boot.kernelPackages = pkgs.linuxPackages_6_4;
    })
  ];

  bootspec.enable = true;

  lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  loader.efi.canTouchEfiVariables = true;

  initrd = {
    kernelModules = [
      "nvme"

      "dm_mod"
      "trusted"
      "encrypted_keys"
      "dm_crypt"

      "blake2b_generic"
      "btrfs"

      "xfs"

      "tpm_tis"
    ];

    luks.devices.crypt0 = {
      allowDiscards = true;
      device = "/dev/disk/by-partlabel/andromeda-crypt0-partition";
      crypttabExtraOpts = [
        "tpm2-device=/dev/tpmrm0"
        "tpm2-pcrs=0+2+7"
      ];
    };

    systemd.enable = true;
  };

  kernelModules = [
    "kvm_intel"

    "dm_cache"
    "dm_raid"
  ];

  kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
  ];

  tmp = {
    tmpfsSize = "16G";
    useTmpfs = true;
  };
}
