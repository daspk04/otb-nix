{
  cmake,
  stdenv,
  swig,
  which,
  boost,
  curl,
  gdal,
  itk_4_13,
  libsvm,
  libgeotiff,
  muparser,
  muparserx,
  opencv,
  perl,
  python,
  shark,
  tinyxml,
  makeWrapper,
  fetchgit,
  lib,
  pkgs,
  ...
}: let
  versionMeta = builtins.fromJSON (builtins.readFile ./version.json);
in
  stdenv.mkDerivation rec {
    pname = "otb";
    version = versionMeta.version;

    src = builtins.fetchGit {
      name = pname;
      url = "https://gitlab.orfeo-toolbox.org/orfeotoolbox/otb";
      ref = "refs/tags/${version}";
      rev = versionMeta.rev;
    };


    nativeBuildInputs = [
      cmake
      makeWrapper
      python.pkgs.wrapPython
      swig
      which
    ];

    buildInputs = [
      boost
      curl
      gdal
      itk_4_13
      libsvm
      libgeotiff
      muparser
      muparserx
      opencv
      perl
      python
      python.pkgs.numpy
      shark
      tinyxml
    ];


    # https://www.orfeo-toolbox.org/CookBook/CompilingOTBFromSource.html#native-build-with-system-dependencies
    # activates all modules and python by default
    # todo: make modules as optional flag, possibly can have similar as gdal package in nix, otbminimal, otbcore ?
    cmakeFlags = [
      "-DOTB_WRAP_PYTHON=ON"
      "-DOTB_BUILD_FeaturesExtraction=ON"
      "-DOTB_BUILD_Hyperspectral=ON"
      "-DOTB_BUILD_Learning=ON"
      "-DOTB_BUILD_Miscellaneous=ON"
      "-DOTB_BUILD_RemoteModules=ON"
      "-DOTB_BUILD_SAR=ON"
      "-DOTB_BUILD_Segmentation=ON"
      "-DOTB_BUILD_StereoProcessing=ON"
      "-DBUILD_TESTING=OFF"
    ];

    # todo: check if these contains all the required packages for another package to be build against OTB (such remote modules) ?
    propagatedBuildInputs = [
      boost
      curl
      gdal
      itk_4_13
      libgeotiff
      libsvm
      muparser
      muparserx
      opencv
      perl
      python
      python.pkgs.numpy
      shark
      swig
      tinyxml
    ];

    pythonPath = [python.pkgs.numpy];

    # wrap the otbcli with the environment variable
    postInstall = ''
      wrapProgram $out/bin/otbcli \
          --set OTB_INSTALL_DIR "$out" \
          --set OTB_APPLICATION_PATH "$out/lib/otb/applications"
    '';

    meta = {
      description = "Orfeo ToolBox";
      homepage = "https://www.orfeo-toolbox.org/";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [daspk04];
    };
  }
