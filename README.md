# otb-nix
This repo contains Nix Flake configuration for building [Orfeo Toolbox](https://www.orfeo-toolbox.org/) 
from source.

## How to use OTB nix package 
NB: Assuming that one has already Nix with Flake enabled.
[Check guide](#guide-on-installation-related-to-nix)

1) First create a directory locally `mkdir otb`
2) Then inside the directory create a `flake.nix` file and copy the content as mentioned below 
```nix
{
  description = "A flake for Orfeo Toolbox";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/24.05";
    flake-utils.url = "github:numtide/flake-utils";
    otbpkgs.url = "github:daspk04/otb-nix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    otbpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        otb = otbpkgs.packages.${system}.otb;
        python = pkgs.python312;
        pyPkgs = python.pkgs;
      in {
        devShells.default = pkgs.mkShell rec {
          packages = with pkgs; [
            otb
            bashInteractive
            pyPkgs.python
            pyPkgs.venvShellHook
          ];
          venvDir = "./.venv";

          otbPath = with pkgs; pkgs.lib.makeLibraryPath [otb];
            
          # add the python path to be able to use otb via python
          postShellHook = ''
            export PYTHONPATH="$PYTHONPATH:${otbPath}/otb/python"
          '';
        };
      }
    );
}
```
3) Then run `nix develop`, this should create a nix shell with python virtual environment `(.venv)`
with `otb` and `python 3.12` enabled. 
4) Now one should be able to use all the [command line](https://www.orfeo-toolbox.org/CookBook/CliInterface.html)
and [python api](https://www.orfeo-toolbox.org/CookBook/PythonAPI.html) as mentioned in documentation.

**Optional:** Step 3 will not be needed if `nix-direnv` is used, it should automatically activate the 
shell environment when one enters the directory. Incase one has already installed `nix-direnv` then 
just copy the [.envrc](.envrc) file in this repo and put it inside the above folder.  


## Advantage of OTB with Nix
- This is highly modular and allows one to customize and build `OTB` with a different version of packages 
as per need such as `GDAL`, `ITK`, etc. as `Nix` already has a lot of [packages]([Nixpkgs](https://search.nixos.org/packages)).
- Building with Nix is almost reproducible.
- This was build out of my requirement, as the current OTB build against GDAL does not support `Geo(Parquet)` and `Blosc` 
compressor for `Zarr` dataset. [Related Issue](https://github.com/remicres/otbtf/issues/95). So this 
Nix pacakge solved those issues as `GDAL` on `Nixpkgs` already has those.
- One can combine OTB with different geospatial python libraries such as `rasterio`, `geopandas` etc. 
which as already available with [Nixpkgs](https://search.nixos.org/packages) no need to create a separate environment.
- There isn't any conda package for OTB, although it is under plan; 
this Nixpkgs should help people who want to use `OTB` with a different python version or packages 
such as (gdal,rasterio, geopandas etc.), which should solve most of those use cases for OTB to be 
imported in an custom python environment [As of today August 2024,].
- One can also build multi-arch version of OTB package apart from `AMD64 (x86_64-linux)` i.e. 
`ARM64 (aarch64-linux)` as currently OTB has no `aarch64-linux` version.
- One can easily build docker image as well.
  
## Advanced Configuration

1) Python Environment: `OTB` + `Pyotb` + `GDAL` + `Rasterio`.
Here is an example of how to create an `flake.nix` with all the above python packages.
`Pyotb` is not available in `Nixpkgs` so we will build it from the source with `Nix`.
```nix
{
  description = "A flake for Orfeo Toolbox";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    otbpkgs.url = "github:daspk04/otb-nix";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
    otbpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        otb = otbpkgs.packages.${system}.otb;
        python = pkgs.python312;
        pyPkgs = python.pkgs;
        
        # Build configuration pyotb 
        pyotb = pyPkgs.buildPythonPackage rec {
          pname = "pyotb";
          version = "2.0.3.dev2";
          format = "pyproject";
          docheck = false;
         
        # Fetch it from github (one can fetch from pypi as well)
          src = builtins.fetchGit {
            name = pname;
            url = "https://github.com/orfeotoolbox/pyotb.git";
            ref = "refs/tags/${version}";
            rev = "de801eae7e2bd80706801df4a48b23998136a5cd";
          };

          nativeBuildInputs = with pyPkgs; [
            setuptools
          ];

          propagatedBuildInputs = with pyPkgs; [
            numpy
          ];
        };
      in {
        devShells.default = pkgs.mkShell rec {
          packages = with pkgs; [
            bashInteractive
            pyPkgs.gdal
            pypkgs.rasterio
            pyPkgs.python
            pyPkgs.venvShellHook
            pyotb
            otb
          ];
          venvDir = "./.venv";

          otbPath = with pkgs; pkgs.lib.makeLibraryPath [otb];

          postShellHook = ''
            export PYTHONPATH="$PYTHONPATH:${otbPath}/otb/python"
          '';
        };
      }
    );
}
```

## Docker
- Docker Image for OTB: 
  - Linux AMD64
  - Linux ARM64: To build OTB for `linux-aarch-64` there are 3 options:
    - The easiest way would be to build natively with ARM64 (Still needs to be tested)
    - Compile using an emulator (Tested with [GitHub Action](https://github.com/daspk04/otb-nix/actions/runs/10191427474) and it builds fine)
    - We can also via nix cross compiler (Still needs to be Tested)

1) One can build a docker image for OTB with python support and no remote modules (default).
```
1) Clone this repo
2) make build_docker
2) docker run -it --rm otb
```
2) One can build a docker image for OTB with python support and all the remote modules.
```
1) Clone this repo
2) make build_dev_docker
2) docker run -it --rm otb-dev
```

### Example 1: 
##### Build a docker image based on `OTB`, `pyotb`, `gdal` and `rasterio` without cloning this repo. 

1) Create a local directory
2) Create a `flake.nix` as shown below which already has the required python packages and as 
it points to this github directory so we don't need to clone.
3) Copy the contents in [docker.nix](docker.nix) file and put it in the local directory.

Local directory should basically contain 2 files (optional copy the Makefile):
```bash
flake.nix
docker.nix
```

4) Run command as mentioned below:

```
1) nix run .\#otb-docker.copyToDockerDaemon
2) docker run -it --rm otb
```
Example of `flake.nix` with `OTB`, `Gdal`, `Pyotb` and `Rasterio`:
```nix
{
  description = "A flake for Orfeo Toolbox";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    otbpkgs.url = "github:daspk04/otb-nix";
    nix2container.url = "github:nlewo/nix2container";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix2container,
    flake-utils,
    otbpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        nix2containerPkgs = nix2container.packages.${system};
        python = pkgs.python312;
        pyPkgs = python.pkgs;
        otb = otbpkgs.packages.${system}.otb.override {
          python3 = python;
          enablePython = true;
        };

        otbPath = with pkgs; pkgs.lib.makeLibraryPath [otb];

        pyotb = pyPkgs.buildPythonPackage rec {
          pname = "pyotb";
          version = "2.0.3.dev2";
          format = "pyproject";
          docheck = false;

          src = builtins.fetchGit {
            name = pname;
            url = "https://github.com/orfeotoolbox/pyotb.git";
            ref = "refs/tags/${version}";
            rev = "de801eae7e2bd80706801df4a48b23998136a5cd";
          };

          nativeBuildInputs = with pyPkgs; [
            setuptools
          ];

          propagatedBuildInputs = with pyPkgs; [
            numpy
          ];
        };
      in rec {
        packages = {
          otb-docker = pkgs.callPackage ./docker.nix {
            inherit pkgs otb nix2containerPkgs;
            img-name = "otb";
            img-tag = "latest";
            python3 = python;
            extra-python-packages = with pyPkgs; [pyotb gdal rasterio];
          };
        };
        devShells.default = pkgs.mkShell rec {
          packages = with pkgs; [
            bashInteractive
            pyPkgs.gdal
            pypkgs.rasterio
            pyPkgs.python
            pyPkgs.venvShellHook
            pyotb
            otb
          ];
          venvDir = "./.venv";

          postShellHook = ''
            export PYTHONPATH="$PYTHONPATH:${otbPath}/otb/python"
          '';
        };
      }
    );
}
```

### Example2: 
Build a docker image based on `OTB`, `pyotb`, `gdal` and `rasterio` without cloning this repo and some specific remote modules

1)  The steps and the command are same as `Example1` except we just change the `flake.nix` file 
and the `otb` section for only remote modules.


Example of `flake.nix` with only activated remote modules such as `prefetch` and `otbtf` [note on OTBTF](#note)
```nix
{
  description = "A flake for Orfeo Toolbox";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    otbpkgs.url = "github:daspk04/otb-nix";
    nix2container.url = "github:nlewo/nix2container";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix2container,
    flake-utils,
    otbpkgs,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        nix2containerPkgs = nix2container.packages.${system};
        python = pkgs.python312;
        pyPkgs = python.pkgs;
        
        ## we only enable Prefetch and Otbtf remote modules
        otb = pkgs.callPackage ./pkgs/otb/. {
            inherit system;
            shark = packages.shark;
            itk_4_13 = packages.itk_4_13;
            gdal = gdal;
            python3 = python; # build otb with fixed python version
            enablePython = true;
            enablePrefetch = true;
            enableOtbtf = true;
          };

        otbPath = with pkgs; pkgs.lib.makeLibraryPath [otb];

        pyotb = pyPkgs.buildPythonPackage rec {
          pname = "pyotb";
          version = "2.0.3.dev2";
          format = "pyproject";
          docheck = false;

          src = builtins.fetchGit {
            name = pname;
            url = "https://github.com/orfeotoolbox/pyotb.git";
            ref = "refs/tags/${version}";
            rev = "de801eae7e2bd80706801df4a48b23998136a5cd";
          };

          nativeBuildInputs = with pyPkgs; [
            setuptools
          ];

          propagatedBuildInputs = with pyPkgs; [
            numpy
          ];
        };
      in rec {
        packages = {
          otb-docker = pkgs.callPackage ./docker.nix {
            inherit pkgs otb nix2containerPkgs;
            img-name = "otb";
            img-tag = "latest";
            python3 = python;
            extra-python-packages = with pyPkgs; [pyotb gdal rasterio];
          };
        };
        devShells.default = pkgs.mkShell rec {
          packages = with pkgs; [
            bashInteractive
            pyPkgs.gdal
            pypkgs.rasterio
            pyPkgs.python
            pyPkgs.venvShellHook
            pyotb
            otb
          ];
          venvDir = "./.venv";

          postShellHook = ''
            export PYTHONPATH="$PYTHONPATH:${otbPath}/otb/python"
          '';
        };
      }
    );
}
```




## Develop
- In case one needs to develop or experiment then
- Clone this repo and make changes and push to your repository 
- Then in the above flake change the `otbpkgs.url` to point to the updated repo url.
```markdown
otbpkgs.url = "github:{userName}/{repoName}?ref={branchName}";
```


### How to build OTB locally
```markdown
1) clone this repo
2) nix build #.otb 
or # nix build #.otb-all --> this will build OTB with all the remote modules
3) ./result/bin/otbcli_BandMathX -help
```

## Guide on installation related to NIX

Nix should be installed and flakes should be enabled. 
`nix-direnv` is optional but is also recommended.
- How to install Nix: 
  - https://zero-to-nix.com/start/install
  - https://nix.dev/install-nix
- How to configure Flake in Nix:
  - https://www.tweag.io/blog/2020-05-25-flakes/
- How to install direnv 
  - https://github.com/nix-community/nix-direnv?tab=readme-ov-file#installation
- How to cross compile in Nix:
  - https://thewagner.net/blog/2023/11/20/building-nix-packages-for-the-raspberry-pi-with-github-actions/
  - https://lgug2z.com/articles/building-and-privately-caching-x86-and-aarch64-nixos-systems-on-github-actions/



## TODO
 - [X] Build a Nix Docker for the OTB package [Linux AMD64 and Linux ARM64]
 - [X] Build OTB with [remote modules]((https://www.orfeo-toolbox.org/CookBook/RemoteModules.html)) (OTBTF, TimeSeriesGapFilling, etc)
 - [ ] Build OTB with Tensorflow for OTBTF (OTBTF remote modules doesn't have Tensorflow)

## NOTE:
- The `OTBTF` build with `Nix` still doesn't have the `TF` applications such as `TensorflowModelServe` 
`ImageClassifierFromDeepFeatures` `TensorflowModelTrain` `TrainClassifierFromDeepFeatures` `ImageClassifierFromDeepFeatures`
as the `TF` building from source via Nix is yet to be done by me.


#### **NOTE: This repo is currently experimental, please open an issue in case you encounter any.**