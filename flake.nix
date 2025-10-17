{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    pyproject-nix = {
      url = "github:nix-community/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-parts,
      systems,
      pyproject-nix,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;
      perSystem =
        {
          self',
          inputs',
          pkgs,
          lib,
          system,
          config,
          ...
        }:
        {
          packages.default =
            let
              python = pkgs.python312;
            in
            python.pkgs.buildPythonPackage (
              (pyproject-nix.lib.project.loadPyproject {
                projectRoot = ./.;
              }).renderers.buildPythonPackage
                { inherit python; }
            );
        };
    };
}
