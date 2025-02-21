# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
{
  self,
  inputs,
  pkgs ? null,
  ...
}: rec {
  inherit
    (pkgs.stdenv.hostPlatform)
    isLinux
    isDarwin
    isx86_64
    isi686
    isArmv7
    isRiscV64
    isRiscV32
    isAarch64
    isAarch32
    ;
  inherit (pkgs.lib.strings) hasSuffix;
  inherit (pkgs.lib) genAttrs;
  allLinuxSystems = [
    "x86_64-linux"
    "aarch64-linux"
    "armv6l-linux"
    "armv7l-linux"
    "riscv64-linux"
  ];
  allDarwinSystems = [
    "x86_64-darwin"
    "aarch64-darwin"
  ];
  allSystemsAttrs = {
    linux = allLinuxSystems;
    darwin = allDarwinSystems;
  };
  allSystems = allSystemsAttrs.darwin ++ allSystemsAttrs.linux;
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  getHomeDirectory = username: homePrefix + "/${username}";
  isArm = isArmv7 || isAarch64 || isAarch32;
  isForeignNix =
    !isNixOS && isLinux && builtins.pathExists "/nix" && !builtins.pathExists "/etc/nixos";
  isNixOS = builtins.pathExists "/etc/nixos" && builtins.pathExists "/nix" && isLinux;
  isPC = isx86_64 || isi686;
  isPC64 = isx86_64;
  isPC32 = isi686;
  isDarwinArm = pkgs.system == "aarch64-darwin";
  isDarwinx86 = pkgs.system == "x86_64-darwin";
  forEachSystem = genAttrs systems;
  forAllEachSystems = genAttrs allSystems;
  homePrefix =
    if isDarwin
    then "/Users"
    else "/home";
  genPkgs = system:
    import inputs.nixpkgs {
      inherit system;
      overlays = builtins.attrValues self.overlays;
      config = self.nixpkgs-config;
    };
    roles = rec {
      rolesList = [
        "clockworkpi-dev"
        "clockworkpi-prod"
        "container"
        "darwin"
        "darwin-arm64"
        "darwin-x86"
        "embedded"
        "gaming"
        "github-runner"
        "gitlab-runner"
        "gpd-duo"
        "jovian"
        "minimal"
        "mobile-nixos"
        "nix-on-droid"
        "personal"
        "proxmox-lxc"
        "proxmox-vm"
        "raspberrypi-arm64"
        "raspberrypi-zero"
        "rnet"
        "shynet"
        "steamdeck"
        "work"
        "workstation"
        "wsl"
      ];
      utils = rec {
        checkRole = role: (builtins.elem role rolesList);
        checkRoleIn = targetRole: hostRoles:
          (builtins.elem targetRole rolesList) && (builtins.elem targetRole hostRoles);
        checkRoles = targetRoles: hostRoles: (builtins.any checkRole targetRoles) && (builtins.any checkRole hostRoles);
        checkAllRoles = targetRoles: hostRoles: (builtins.all checkRole targetRoles) && (builtins.all checkRole hostRoles);
      };
    };
}
