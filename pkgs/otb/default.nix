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
  clangStdenv,
  fetchFromGitHub,
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
  tensorflow ? null,
  enableFFTW ? false,
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
  enableTf ? false,
  enableMLUtils ? false,
  enableNormlimSigma0 ? false,
  enablePhenology ? false,
  enableRTCGamma0 ? false,
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

  stdenv = clangStdenv;

  inherit (lib) optionalString optionals optional;
  pythonInputs =
    optionals enablePython
    (with python3.pkgs; [
      numpy
    ])
    ++ optionals enableTf [ tensorflow ]
    ++ (extraPythonPackages python3.pkgs);
  otb-shark = shark.override {enableOpenMP = enableOpenMP;};
  otb-itk =  itk_4_13.override {enableFFTW = enableFFTW;};

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
  otbNormlimSigma0 = pkgs.callPackage ./otb-s1tiling-normlimsigma0/. {};
  otbRTCGamma0 = pkgs.callPackage ./otb-s1tiling-rtcgamma0/. {};
in
  stdenv.mkDerivation (finalAttrs: {
  pname = "otb";
  version = "9.1.1";

  src = fetchFromGitHub {
    owner = "orfeotoolbox";
    repo = "OTB";
    tag = finalAttrs.version;
    hash = "sha256-xRUFbMSXbg60X1G29fSNqgKcGbWIBwl9gEb+T6f35MI=";
  };

    postPatch = lib.concatStringsSep "\n" (
      (optionals enableMLUtils ["ln -sr ${mlUtils} Modules/Remote/MLUtils"])
      ++ (optionals enablePrefetch ["ln -sr ${otbPrefetch} Modules/Remote/OTBPrefetch"])
      ++ (optionals enableOtbtf [
        "cp --no-preserve=mode -r ${otbTF} Modules/Remote/otbtf"
        "substituteInPlace Modules/Remote/otbtf/include/otbTensorflowCopyUtils.cxx --replace-fail 'values.size()' 'static_cast<long>(values.size())'"
      ])
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
      ++ (optionals enableNormlimSigma0 [
      "cp --no-preserve=mode -r ${otbNormlimSigma0} Modules/Remote/SARCalibrationExtended"
      "substituteInPlace Modules/Remote/SARCalibrationExtended/include/Filters/otbSARCartesianMeanFunctor2.h --replace 'for(auto ind = 0ull, nbElt = outValue.size(); ind < nbElt; ind++)' 'for(std::size_t ind = 0, nbElt = outValue.size(); ind < nbElt; ind++)'"
      ])
      ++ (optionals enableRTCGamma0 [
      "cp --no-preserve=mode -r ${otbRTCGamma0} Modules/Remote/SARCalibrationRTCGamma0"
      "substituteInPlace Modules/Remote/SARCalibrationRTCGamma0/otb-module.cmake --replace 'OTBApplicationEngine' 'OTBApplicationEngine\n    OTBTransform'"
      "substituteInPlace Modules/Remote/SARCalibrationRTCGamma0/src/CMakeLists.txt --replace 'target_link_libraries(''$\{otb-module} ''$\{OTBCommon_LIBRARIES} ''$\{OTBITK_LIBRARIES} ''$\{OTBOSSIMAdapters_LIBRARIES})' 'target_link_libraries(''$\{otb-module} ''$\{OTBCommon_LIBRARIES} ''$\{OTBImageBase_LIBRARIES} ''$\{OTBIOGDAL_LIBRARIES} ''$\{OTBTransform_LIBRARIES} ''$\{OTBITK_LIBRARIES} ''$\{OTBOSSIMAdapters_LIBRARIES})'"
    ])
      ++ [
      (''
        substituteInPlace CMakeLists.txt --replace-fail "CXX_STANDARD" ""
        substituteInPlace Modules/ThirdParty/6S/src/otb_6S_f2c.h --replace-fail "register " ""
      '')
    ]
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
        otb-itk
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
        (lib.cmakeBool "OTB_USE_TENSORFLOW" enableTf)
        "-DModule_OTBTensorflow=ON"
      ]
      ++ optionals enableTf [
        "-Dtensorflow_include_dir=${tensorflow}/${python3.pkgs.python.sitePackages}/tensorflow/include"
        "-DTENSORFLOW_CC_LIB=${tensorflow}/${python3.pkgs.python.sitePackages}/tensorflow/libtensorflow_cc.so.2"
        "-DTENSORFLOW_FRAMEWORK_LIB=${tensorflow}/${python3.pkgs.python.sitePackages}/tensorflow/libtensorflow_framework.so.2"
      ]
      ++ optionals enableMLUtils [
        "-DModule_MLUtils=ON"
      ]
      ++ optionals enableNormlimSigma0 [
        "-DModule_SARCalibrationExtended=ON"
      ]
      ++ optionals enablePhenology [
        "-DModule_OTBPhenology=ON"
      ]
      ++ optionals enableRTCGamma0 [
        "-DModule_SARCalibrationRTCGamma0=ON"
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
      ]
      ++ optionals enableFFTW (lib.cmakeBool "OTB_USE_FFTW" true);

    propagatedBuildInputs =
      []
      ++ pythonInputs;

    doInstallCheck = false;

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
  })
