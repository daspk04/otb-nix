{
  cmake,
  fetchgit,
  makeWrapper,
  lib,
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
  python3,
  shark,
  tinyxml,
  enableFeatureExtraction ? true,
  enableHyperspectral ? true,
  enableLearning ? true,
  enableMiscellaneous ? true,
  enableOpenMP ? false,
  enablePython ? true,
  extraPythonPackages ? ps: with ps; [],
  enableRemote ? true,
  enableSAR ? true,
  enableSegmentation ? true,
  enableStereoProcessing ? true,
  pkgs,
  ...
}: let
  versionMeta = builtins.fromJSON (builtins.readFile ./version.json);

  inherit (lib) optionalString optionals optional;
  pythonInputs =
    optionals enablePython
    (with python3.pkgs; [
      numpy
    ])
    ++ (extraPythonPackages python3.pkgs);
  otb-shark = shark.override {enableOpenMP = enableOpenMP;};
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

    nativeBuildInputs =
      [
        cmake
        makeWrapper
        swig
        which
      ]
      ++ optionals enablePython [
        python3.pkgs.wrapPython
      ];

    buildInputs =
      [
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
        otb-shark
        tinyxml
      ]
      ++ optionals enablePython [
        python3
      ]
      ++ optionals enablePython pythonInputs;

    # https://www.orfeo-toolbox.org/CookBook/CompilingOTBFromSource.html#native-build-with-system-dependencies
    cmakeFlags =
      [
      ]
      ++ optionals enableFeatureExtraction [
        "-DOTB_BUILD_FeaturesExtraction=ON"
      ]
      ++ optionals enableHyperspectral [
        "-DOTB_BUILD_Hyperspectral=ON"
      ]
      ++ optionals enableLearning [
        "-DOTB_BUILD_Learning=ON"
      ]
      ++ optionals enableMiscellaneous [
        "-DOTB_BUILD_Miscellaneous=ON"
      ]
      ++ optionals enableRemote [
        "-DOTB_BUILD_RemoteModules=ON"
      ]
      ++ optionals enableSAR [
        "-DOTB_BUILD_SAR=ON"
      ]
      ++ optionals enableSegmentation [
        "-DOTB_BUILD_Segmentation=ON"
      ]
      ++ optionals enableStereoProcessing [
        "-DOTB_BUILD_StereoProcessing=ON"
      ]
      ++ optionals enablePython [
        "-DOTB_WRAP_PYTHON=ON"
      ]
      ++ optionals doInstallCheck [
        "-DBUILD_TESTING=ON"
      ];

    propagatedBuildInputs =
      []
      ++ pythonInputs;

    doInstallCheck = false;

    computed_PATH = lib.makeBinPath propagatedBuildInputs;

    # Make PATH available to subprocesses
    makeWrapperArgs = [
        "--prefix PATH : ${computed_PATH}"
    ];

    #    pythonPath = optionals enablePython pythonInputs ++ ["$out/lib/otb/python"];

    # wrap the otbcli with the environment variable
    postInstall = ''
      wrapProgram $out/bin/otbcli \
          --set OTB_INSTALL_DIR "$out" \
          --set OTB_APPLICATION_PATH "$out/lib/otb/applications"
    '';

    #  # todo: this still doesn't fix importing of otb via python
    #  postFixup = ''
    #    wrapPythonProgramsIn "$out/lib/otb/python" "$out $pythonPath"
    #  '';

    meta = {
      description = "Orfeo ToolBox";
      homepage = "https://www.orfeo-toolbox.org/";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [daspk04];
    };
  }
