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
  gsl,
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
  enablePrefetch ? false,
  enableOtbtf ? false,
  enableMLUtils ? false,
  enablePhenology ? false,
  enableBioVars ? false,
  enableGRM ? false,
  enableLSGRM ? false,
  enableSimpleExtraction ? false,
  enableTemporalGapfilling ? false,
  enableTimeSeriesUtils ? false,
  enableTemporalSmoothing ? false,
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

  # remote modules based on :
  # https://forgemia.inra.fr/orfeo-toolbox
  # https://gitlab.orfeo-toolbox.org/orfeotoolbox/otb/-/tree/develop/Modules/Remote?ref_type=heads
  mlUtils = pkgs.callPackage ./otb-mlutils/. {};
  otbPrefetch = pkgs.callPackage ./otb-prefetch/. {};
  otbTF = pkgs.callPackage ./otbtf/. {};
  otbPhenology = pkgs.callPackage ./phenotb/. {};
  otbBioVars = pkgs.callPackage ./otb-bv/. {};
  otbGRM = pkgs.callPackage ./otb-GRM/. {};
  otbLSGRM = pkgs.callPackage ./otb-LSGRM/. {};
  otbSeTools = pkgs.callPackage ./otb-simpleextractiontools/. {};
  otbTempGapfill = pkgs.callPackage ./otb-temporalgapfilling/. {};
  otbTsUtils = pkgs.callPackage ./otb-timeseriesutils/. {};
  otbTsSmooth = pkgs.callPackage ./otb-temporalsmoothing/. {};
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

    postPatch = lib.concatStringsSep "\n" (
      (optionals enableMLUtils ["ln -sr ${mlUtils} Modules/Remote/MLUtils"])
      ++ (optionals enablePrefetch ["ln -sr ${otbPrefetch} Modules/Remote/OTBPrefetch"])
      ++ (optionals enableOtbtf ["ln -sr ${otbTF} Modules/Remote/otbtf"])
      ++ (optionals enablePhenology [
        "ln -sr ${otbPhenology} Modules/Remote/OTBPhenology"
        "rm Modules/Remote/phenotb.remote.cmake"
      ])
      ++ (optionals enableBioVars [
        "ln -sr ${otbBioVars} Modules/Remote/OTBBioVars"
        "rm Modules/Remote/otb-bv.remote.cmake"
      ])
      ++ (optionals enableGRM [
        "ln -sr ${otbGRM} Modules/Remote/OTBGRM"
        "rm Modules/Remote/otbGRM.remote.cmake"
      ])
      ++ (optionals enableLSGRM [
        "cp --no-preserve=mode -r ${otbLSGRM} Modules/Remote/OTBLSGRM"
        "substituteInPlace Modules/Remote/OTBLSGRM/otb-module.cmake --replace \"OTBMPI\" \"\""
      ])
      ++ (optionals enableSimpleExtraction ["ln -sr ${otbSeTools} Modules/Remote/OTBSimpleExtractionTools"])
      ++ (optionals enableTemporalGapfilling [
        "ln -sr ${otbTempGapfill} Modules/Remote/OTBTemporalGapFilling"
        "rm Modules/Remote/temporal-gapfilling.remote.cmake"
      ])
      ++ (optionals enableTimeSeriesUtils ["ln -sr ${otbTsUtils} Modules/Remote/OTBTimeSeriesUtils"])
      ++ (optionals enableTemporalSmoothing ["ln -sr ${otbTsSmooth} Modules/Remote/OTBTemporalSmoothing"])
    );
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
      ++ optionals enableTemporalGapfilling
      [
        gsl
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
      ]
      ++ optionals enablePrefetch [
        "-DModule_OTBPrefetch=ON"
      ]
      ++ optionals enableOtbtf [
        "-DOTB_USE_TENSORFLOW=OFF"
        "-DModule_OTBTensorflow=ON"
      ]
      ++ optionals enableMLUtils [
        "-DModule_MLUtils=ON"
      ]
      ++ optionals enablePhenology [
        "-DModule_OTBPhenology=ON"
      ]
      ++ optionals enableBioVars [
        "-DModule_OTBBioVars=ON"
      ]
      ++ optionals enableGRM [
        "-DModule_otbGRM=ON"
      ]
      ++ optionals enableLSGRM [
        "-DModule_LSGRM=ON"
      ]
      ++ optionals enableSimpleExtraction [
        "-DModule_SimpleExtractionTools=ON"
      ]
      ++ optionals enableTemporalGapfilling [
        "-DModule_OTBTemporalGapFilling=ON"
      ]
      ++ optionals enableTimeSeriesUtils [
        "-DModule_TimeSeriesUtils=ON"
      ]
      ++ optionals enableTemporalSmoothing [
        "-DModule_TemporalSmoothing=ON"
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
