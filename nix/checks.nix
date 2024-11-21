# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
{
  system,
  inputs,
  lib,
  self,
  ...
}:
inputs.git-hooks.lib.${system}.run {
  src = lib.cleanSource "${self}/.";
  hooks = {
    deadnix.enable = true;
    alejandra.enable = true;
    yamlfmt.enable = true;
    actionlint.enable = true;
    statix = {
      enable = false;
      settings.ignore = [
        "flake.nix"
        "*-compose.nix"
        "mautrix-whatsapp.nix"
        "mautrix-slack.nix"
        ".devenv"
        ".direnv"
      ];
    };
  };
}
