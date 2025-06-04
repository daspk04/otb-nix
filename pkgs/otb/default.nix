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
  pkgs,
  clangStdenv,
  lib,
  stdenv,

  gsl,
  otb,
  itk,
  python3,
  tensorflow ? null,
  onnxruntime,

  # otb modules
  enableFFTW ? false,
  enableFeatureExtraction ? true,
  enableHyperspectral ? true,
  enableLearning ? true,
  enableMiscellaneous ? true,
  enableOpenMP ? false,
  enablePython ? true,
  extraPythonPackages ? ps: with ps; [ ],
  enableRemote ? true,
  enableSAR ? true,
  enableSegmentation ? true,
  enableShark ? true,
  enableStereoProcessing ? true,
  enableThirdParty ? true,

  # otb remote modules
  enablePrefetch ? false,
  enableOtbtf ? false,
  enableOtbOnnx ? false,
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

  ...
}:
let
  inherit (lib) optionalString optionals optional;
  stdenv = clangStdenv;

  # remote modules based on :
  # https://forgemia.inra.fr/orfeo-toolbox
  # https://gitlab.orfeo-toolbox.org/orfeotoolbox/otb/-/tree/develop/Modules/Remote?ref_type=heads
  mlUtils = pkgs.callPackage ./otb-mlutils/. { };
  otbOnnx = pkgs.callPackage ./otb-onnx/. { };
  otbPrefetch = pkgs.callPackage ./otb-prefetch/. { };
  otbTF = pkgs.callPackage ./otbtf/. { };
  otbPhenology = pkgs.callPackage ./phenotb/. { };
  otbBioVars = pkgs.callPackage ./otb-bv/. { };
  otbGRM = pkgs.callPackage ./otb-GRM/. { };
  otbLSGRM = pkgs.callPackage ./otb-LSGRM/. { };
  otbSeTools = pkgs.callPackage ./otb-simpleextractiontools/. { };
  otbTempGapfill = pkgs.callPackage ./otb-temporalgapfilling/. { };
  otbTsUtils = pkgs.callPackage ./otb-timeseriesutils/. { };
  otbTsSmooth = pkgs.callPackage ./otb-temporalsmoothing/. { };
  otbNormlimSigma0 = pkgs.callPackage ./otb-s1tiling-normlimsigma0/. { };
  otbRTCGamma0 = pkgs.callPackage ./otb-s1tiling-rtcgamma0/. { };
#  otbITK = itk.overrideAttrs (oldArgs: {
#      cmakeFlags = oldArgs.cmakeFlags or [ ] ++ [
#      (lib.cmakeBool "Module_ITKDeprecated" true)
#      (lib.cmakeBool "VNL_CONFIG_LEGACY_METHODS" true)
#      (lib.cmakeBool "ITKV4_COMPATIBILITY" true)
#      ];
#  });
in
(otb.override {
  stdenv = stdenv;
  python3 = python3;
#  itk = otbITK;
  enableFFTW = enableFFTW;
  enableFeatureExtraction = enableFeatureExtraction;
  enableHyperspectral = enableHyperspectral;
  enableLearning = enableLearning;
  enableMiscellaneous = enableMiscellaneous;
  enableOpenMP = enableOpenMP;
  enablePython = enablePython;
  extraPythonPackages = extraPythonPackages;
  enableRemote = enableRemote;
  enableShark = enableShark;
  enableSAR = enableSAR;
  enableSegmentation = enableSegmentation;
  enableStereoProcessing = enableStereoProcessing;
  enableThirdParty = enableThirdParty;
}).overrideAttrs
  (oldAttrs: {
    doInstallCheck = false;
    # Add postPatch for the modules
    postPatch =
      (oldAttrs.postPatch or "")
      + "\n"
      + lib.concatStringsSep "\n" (
        (optionals enableMLUtils [ "ln -sr ${mlUtils} Modules/Remote/MLUtils" ])
        ++ (optionals enablePrefetch [ "ln -sr ${otbPrefetch} Modules/Remote/OTBPrefetch" ])
        ++ (optionals enableOtbtf [
          "cp --no-preserve=mode -r ${otbTF} Modules/Remote/otbtf"
          "substituteInPlace Modules/Remote/otbtf/include/otbTensorflowCopyUtils.cxx --replace-fail 'values.size()' 'static_cast<long>(values.size())'"
          # remove otbtf independent apps
          # https://github.com/remicres/otbtf/issues/101
          "sed -i '/^# Tensorflow-independent APPS$/,$ d' Modules/Remote/otbtf/app/CMakeLists.txt"
        ])
        ++ (optionals enableOtbOnnx [
          "cp --no-preserve=mode -r ${otbOnnx} Modules/Remote/OTBONNX"
          "substituteInPlace Modules/Remote/OTBONNX/include/otbONNXConversion.cxx --replace-fail 'out.size()' 'static_cast<long>(out.size())'"
        ])
        ++ (optionals enablePhenology [
          "cp --no-preserve=mode -r ${otbPhenology} Modules/Remote/OTBPhenology"
          "rm Modules/Remote/phenotb.remote.cmake"
          "substituteInPlace Modules/Remote/OTBPhenology/src/phenoFunctions.cxx --replace-fail 'vnl_math_sqr(' 'vnl_math::sqr('"
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
        ++ (optionals enableSimpleExtraction [
          "ln -sr ${otbSeTools} Modules/Remote/OTBSimpleExtractionTools"
        ])
        ++ (optionals enableTemporalGapfilling [
          "cp --no-preserve=mode -r ${otbTempGapfill} Modules/Remote/OTBTemporalGapFilling"
          "rm Modules/Remote/temporal-gapfilling.remote.cmake"
          "substituteInPlace Modules/Remote/OTBTemporalGapFilling/include/otbTemporalGapFilling.h --replace-fail 'return (this->dates != a.dates) || (this->dv != a.dv) ;' 'return (this->dv != a.dv) ;'"
        ])
        ++ (optionals enableTimeSeriesUtils [ "ln -sr ${otbTsUtils} Modules/Remote/OTBTimeSeriesUtils" ])
        ++ (optionals enableTemporalSmoothing [
          "ln -sr ${otbTsSmooth} Modules/Remote/OTBTemporalSmoothing"
        ])
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

    # Add the cmake flags for enabling the modules
    cmakeFlags =
      (oldAttrs.cmakeFlags or [ ])
      ++ optional enablePrefetch (lib.cmakeBool "Module_OTBPrefetch" true)
      ++ optional enableOtbtf [
        (lib.cmakeBool "OTB_USE_TENSORFLOW" enableTf)
        (lib.cmakeBool "Module_OTBTensorflow" true)
      ]
      ++ optional enableTf [
        "-Dtensorflow_include_dir=${tensorflow}/${python3.pkgs.python.sitePackages}/tensorflow/include"
        "-DTENSORFLOW_CC_LIB=${tensorflow}/${python3.pkgs.python.sitePackages}/tensorflow/libtensorflow_cc.so.2"
        "-DTENSORFLOW_FRAMEWORK_LIB=${tensorflow}/${python3.pkgs.python.sitePackages}/tensorflow/libtensorflow_framework.so.2"
      ]
      ++ optional enableOtbOnnx [
        (lib.cmakeBool "Module_OTBONNX" true)
        "-DONNX_RUNTIME_LIB=${onnxruntime}/lib/libonnxruntime.so"
        "-DONNX_INCLUDE_DIR=${onnxruntime.dev}/include/"
      ]
      ++ optional enableMLUtils (lib.cmakeBool "Module_MLUtils" true)
      ++ optional enableNormlimSigma0 (lib.cmakeBool "Module_SARCalibrationExtended" true)
      ++ optional enablePhenology (lib.cmakeBool "Module_OTBPhenology" true)
      ++ optional enableRTCGamma0 (lib.cmakeBool "Module_SARCalibrationRTCGamma0" true)
      ++ optional enableBioVars (lib.cmakeBool "Module_OTBBioVars" true)
      ++ optional enableGRM (lib.cmakeBool "Module_otbGRM" true)
      ++ optional enableLSGRM (lib.cmakeBool "Module_LSGRM" true)
      ++ optional enableSimpleExtraction (lib.cmakeBool "Module_SimpleExtractionTools" true)
      ++ optional enableTemporalGapfilling (lib.cmakeBool "Module_OTBTemporalGapFilling" true)
      ++ optional enableTimeSeriesUtils (lib.cmakeBool "Module_TimeSeriesUtils" true)
      ++ optional enableTemporalSmoothing (lib.cmakeBool "Module_TemporalSmoothing" true);

    buildInputs = (oldAttrs.buildInputs or []) ++ optionals enableTemporalGapfilling [ gsl ] ++ optionals enableOtbOnnx [ onnxruntime onnxruntime.dev ];
    propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or []) ++ optionals enableTf [ tensorflow ];

  })
