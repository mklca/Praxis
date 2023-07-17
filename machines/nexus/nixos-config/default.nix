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
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    inputs.cells.common.nixosModules.default

    ({config, ...}: {
      fileSystems = let
        commonBtrfsOptions = [
          "commit=300"
          "compress=zstd:3"
          "discard"
          "noatime"
          "ssd"
        ];

        commonBtrfsSubvolOptions = subvol: commonBtrfsOptions ++ ["subvol=${subvol}"];

        deviceFsSubvol = device: subvol: overrides @ {...}:
          overrides
          // {
            inherit device;
            fsType = "btrfs";
            options = commonBtrfsSubvolOptions subvol;
          };

        systemFsSubvol = deviceFsSubvol "/dev/disk/by-partlabel/nexus-system-partition";
      in {
        "/home" = systemFsSubvol "home" {};

        "/host/Source" = {
          fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
          device = ".host:/Source";
          noCheck = true;
          options = let
            cfgUsers = config.users.users;
            cfgGroups = config.users.groups;

            # Should make this into an option
            owner = "em";
            group = ownerCfg.group;

            ownerCfg = cfgUsers."${owner}";
            groupCfg = cfgGroups."${ownerCfg.group}";
          in [
            "allow_other"
            "auto_unmount"
            "gid=${builtins.toString groupCfg.gid}"
            "uid=${builtins.toString ownerCfg.uid}"
            "x-systemd.automount"
          ];
        };

        "/nix" = systemFsSubvol "nix" {};

        "/persist" = systemFsSubvol "persist" {
          neededForBoot = true;
        };

        "/var/log" = systemFsSubvol "log" {
          neededForBoot = true;
        };
      };
    })
  ];

  boot = {
    loader.systemd-boot.enable = true;

    initrd = {
      availableKernelModules = [
        "ata_piix"
        "mptspi"
        "sr_mod"
      ];

      kernelModules = [
        "nvme"
        "btrfs"
      ];
    };

    kernelModules = [
      "kvm-intel"
    ];

    kernelPackages = inputs.nixpkgs.linuxPackages_6_4;
  };

  fonts.fonts = [
    inputs.nixpkgs.nerdfonts
  ];

  hardware = {
    opengl.enable = true;
    pulseaudio.enable = true;
  };

  home-manager.users.em = builtins.removeAttrs cell.homeConfigurations."em@nexus" ["bee"];

  networking = {
    hostName = "nexus";

    defaultGateway = {
      address = "192.168.103.2";
      interface = "vmen0";
    };

    interfaces = {
      vmen0 = {
        useDHCP = false;
        ipv4.addresses = [
          {
            address = "192.168.103.10";
            prefixLength = 24;
          }
        ];
      };
    };

    nameservers = [
      "192.168.103.2"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  services = {
    avahi = {
      enable = true;

      allowInterfaces = [
        "vmen0"
      ];

      nssmdns = true;

      publish = {
        addresses = true;
        enable = true;
      };
    };

    openssh = {
      enable = true;
      settings.X11Forwarding = true;
    };

    printing.enable = true;

    xserver = {
      enable = true;
      videoDrivers = ["vmware"];

      desktopManager.gnome.enable = true;

      displayManager.gdm = {
        autoSuspend = false;
        enable = true;
      };
    };

    udev.extraRules = ''
      SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:0c:29:07:57:cc", NAME="vmen0"
    '';
  };

  sound.enable = true;

  swapDevices = [
    {
      device = "/dev/disk/by-partlabel/nexus-swap0-partition";
    }
  ];

  virtualisation.vmware.guest = {
    enable = true;
    headless = false;
  };

  system.stateVersion = "21.11";
}
