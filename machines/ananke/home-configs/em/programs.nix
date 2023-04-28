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
  git.extraConfig.credential.helper = "/usr/local/share/gcm-core/git-credential-manager-core";
  ssh.extraConfig = ''
    XAuthLocation /usr/bin/xauth
  '';
}
