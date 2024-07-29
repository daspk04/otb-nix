{
  description = "A flake for Orfeo Toolbox";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        python = pkgs.python312; # we fix python version to 3.12 here for the OTB
      in rec {
        packages.shark = pkgs.callPackage ./pkgs/shark/. {inherit system;};
        packages.itk_4_13 = pkgs.callPackage ./pkgs/itk_4_13_3/. {inherit system;};
        packages.otb = pkgs.callPackage ./pkgs/otb/. {
          inherit system;
          shark = packages.shark;
          itk_4_13 = packages.itk_4_13;
          python3 = python; # build otb with fixed python version
          enablePython = true;
        };
        packages.default = packages.otb;
        devShells.default = pkgs.mkShell rec {
          packages = with pkgs; [
            bashInteractive
            python
          ];
        };
      }
    );
}
