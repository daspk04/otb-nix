{
  description = "A flake for Orfeo Toolbox";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix2container.url = "github:nlewo/nix2container";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix2container,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        python = pkgs.python312; # we fix python version to 3.12 here for the OTB
        nix2containerPkgs = nix2container.packages.${system};
        # The minimal version of gdal and doesn't have arrow support but helps in leaner build
        # we can mix as per requiremnt which will compile gdal from source
        # https://github.com/NixOS/nixpkgs/blob/8c50662509100d53229d4be607f1a3a31157fa12/pkgs/development/libraries/gdal/default.nix#L7
#         gdal = pkgs.gdalMinimal.override {python3 = python;};
#         gdal = pkgs.gdalMinimal.override {python3 = python;
#                                            useArrow = true;
#                                            useHDF = true;
#                                            useNetCDF = true;};
        gdal = pkgs.gdal; # gdal full version
        pyPkgs = python.pkgs;
      in rec {
        packages = {
          shark = pkgs.callPackage ./pkgs/shark/. {inherit system;};
          itk_4_13 = pkgs.callPackage ./pkgs/itk_4_13_3/. {inherit system;};
          otb = pkgs.callPackage ./pkgs/otb/. {
            inherit system;
            shark = packages.shark;
            itk_4_13 = packages.itk_4_13;
            gdal = gdal;
            python3 = python; # build otb with fixed python version
            enablePython = true;
          };

          otb-docker-x86_64 = pkgs.callPackage ./docker.nix {
            inherit pkgs nix2containerPkgs;
            img-name = "otb";
            img-tag = "latest";
            otb = packages.otb;
            python3 = python;
            extra-python-packages = with pyPkgs; [packages.otb.propagatedBuildInputs];
          };

          #          otb-aarch64 = pkgs.pkgsCross.aarch64-multiplatform.callPackage ./pkgs/otb/. {
          #            inherit system;
          #            shark = packages.shark;
          #            itk_4_13 = packages.itk_4_13;
          #            python3 = python; # build otb with fixed python version
          #            enablePython = true;
          #          };

          default = packages.otb;
        };
        devShells.default = pkgs.mkShell rec {
          packages = with pkgs; [
            bashInteractive
            pyPkgs.python
            pyPkgs.venvShellHook
          ];
          venvDir = "./.venv";
        };
      }
    );
}
