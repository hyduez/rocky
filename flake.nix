{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    zig.url = "github:mitchellh/zig-overlay";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    # sops-nix.url = "github:mic92/sops-nix";
    # sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      systems = [ "x86_64-linux" ];

      perSystem =
        {
          system,
          config,
          pkgs,
          ...
        }:
        {

          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                zigpkgs = inputs.zig.packages.${prev.system};
              })
            ];
          };

          formatter = config.treefmt.build.wrapper;

          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.bashInteractive
              pkgs.zigpkgs.master
            ];
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              zig.enable = true;
            };
          };
        };
    };
}
