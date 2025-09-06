# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
{
  description = "Helper functions for my NixOS flakes";

  outputs = inputs: let
    inherit (inputs) self;
    genPkgs = system:
      import inputs.nixpkgs {
        inherit system;
        config = self.nixpkgs-config;
      };

    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    allSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "armv6l-linux"
      "armv7l-linux"
      "riscv64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    treeFmtEachSystem = f: inputs.nixpkgs.lib.genAttrs systems (system: f inputs.nixpkgs.legacyPackages.${system});
    treeFmtEval = treeFmtEachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./nix/formatter.nix);

    forEachSystem = inputs.nixpkgs.lib.genAttrs systems;
    forAllSystems = inputs.nixpkgs.lib.genAttrs allSystems;
  in {
    helpers = {
      formatter = ./nix/formatter.nix;
      checks = ./nix/checks.nix;
      devShells = ./nix/devshell.nix;
    };
    libx = forAllSystems (
      system: let
        pkgs = genPkgs system;
      in
        import ./lib {inherit self inputs pkgs;}
    );
    # for `nix fmt`
    formatter = treeFmtEachSystem (pkgs: treeFmtEval.${pkgs.system}.config.build.wrapper);
    # for `nix flake check`
    checks =
      treeFmtEachSystem (pkgs: {
        formatting = treeFmtEval.${pkgs.system}.config.build.wrapper;
      })
      // forEachSystem (system: {
        pre-commit-check = import ./nix/checks.nix {
          inherit self system inputs;
          inherit (inputs.nixpkgs) lib;
        };
      });
    devShells = forEachSystem (
      system: let
        pkgs = genPkgs system;
      in
        import ./nix/devshell.nix {inherit pkgs self system;}
    );
    nixpkgs-config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
      allowBroken = true;
      allowInsecurePredicate = _: true;
    };
  };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-compat = {
      url = "github:edolstra/flake-compat?ref=v1.1.0";
      flake = false;
    };
    agenix = {
      url = "github:ryantm/agenix?ref=0.15.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    flake-utils.url = "github:numtide/flake-utils?ref=v1.0.0";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
}
