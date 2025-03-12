#   Copyright 2024 Pratyush Das
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
{
  description = "A flake for Orfeo Toolbox";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
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

          otb-dev = pkgs.callPackage ./pkgs/otb/. {
            inherit system;
            shark = packages.shark;
            itk_4_13 = packages.itk_4_13;
            gdal = gdal;
            python3 = python; # build otb with fixed python version
            enablePython = true;
            enablePrefetch = true;
            enableOtbtf = true;
            enableMLUtils = true;
            enableNormlimSigma0 = true;
            enablePhenology = true;
            enableRTCGamma0 = true;
            enableBioVars = true;
            enableGRM = true;
            enableLSGRM = true;
            enableSimpleExtraction = true;
            enableTemporalGapfilling = true;
            enableTimeSeriesUtils = true;
            enableTemporalSmoothing = true;
          };

          otb-docker = pkgs.callPackage ./docker.nix {
            inherit pkgs nix2containerPkgs;
            img-name = "otb";
            img-tag = "latest";
            otb = packages.otb;
            python3 = python;
            extra-python-packages = with pyPkgs; [packages.otb.propagatedBuildInputs];
          };

          otb-dev-docker = pkgs.callPackage ./docker.nix {
            inherit pkgs nix2containerPkgs;
            img-name = "otb-dev";
            img-tag = "latest";
            otb = packages.otb-dev;
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
