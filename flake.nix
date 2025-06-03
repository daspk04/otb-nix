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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix2container.url = "github:nlewo/nix2container";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nix2container,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        python = pkgs.python312; # we fix python version to 3.12 here for the OTB
        nix2containerPkgs = nix2container.packages.${system};
        otb = pkgs.otb;
        tensorflow = pyPkgs.tensorflow-bin;
        pyPkgs = python.pkgs;
      in
      rec {
        packages = {
          # override the tensorflow package with required header files for
          tensorflow = pkgs.callPackage ./pkgs/tensorflow/. {
            inherit system;
            python = pyPkgs.python;
            tensorflow = tensorflow;
          };
          otb = pkgs.callPackage ./pkgs/otb/. {
            inherit system;
            otb = otb;
            python3 = python; # build otb with fixed python version
            enablePython = true;
          };

          # commented modules are broken on ITK 5.3,0
          otb-dev = pkgs.callPackage ./pkgs/otb/. {
            inherit system;
            otb = otb;
            python3 = python; # build otb with fixed python version
            enablePython = true;
            enablePrefetch = true;
            enableOtbtf = true;
            enableMLUtils = true;
#            enableNormlimSigma0 = true;
            enablePhenology = true;
#            enableRTCGamma0 = true;
            enableBioVars = true;
            enableGRM = true;
#            enableLSGRM = true;
            enableSimpleExtraction = true;
            enableTemporalGapfilling = true;
            enableTimeSeriesUtils = true;
            enableTemporalSmoothing = true;
            enableTf = true;
            tensorflow = packages.tensorflow;
          };

          otb-docker = pkgs.callPackage ./docker.nix {
            inherit pkgs nix2containerPkgs;
            img-name = "otb";
            img-tag = "latest";
            otb = packages.otb;
            python3 = python;
            extra-python-packages = with pyPkgs; [ packages.otb.propagatedBuildInputs ];
          };

          otb-dev-docker = pkgs.callPackage ./docker.nix {
            inherit pkgs nix2containerPkgs;
            img-name = "otb-dev";
            img-tag = "latest";
            otb = packages.otb-dev;
            python3 = python;
            extra-python-packages = with pyPkgs; [ packages.otb.propagatedBuildInputs ];
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
            bump-my-version
          ];
          venvDir = "./.venv";
        };
      }
    );
}
