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
  mlUtils = builtins.fetchGit {
    name = "otb-mlutils";
    url = "https://forgemia.inra.fr/orfeo-toolbox/otb-mlutils.git";
    ref = "master";
    rev = "4f6de3654b249de98d5d5fef9c4bf4b623280ce4";
  };

  otbPrefetch = builtins.fetchGit {
    name = "otb-prefetch";
    url = "https://github.com/remicres/otb-prefetch.git";
    ref = "main";
    rev = "1faaa10d79e393bd45da95dde590f4857910c0ce";
  };

  otbTF = builtins.fetchGit {
    name = "otbtf";
    url = "https://forgemia.inra.fr/orfeo-toolbox/otbtf.git";
    ref = "refs/tags/r4.3.1";
    rev = "c9b02fb7d1ed5c28a45dc40dd15bfb4b59b77e95";
  };

  otbPhenology = builtins.fetchGit {
    name = "otb-phenology";
    url = "https://gitlab.orfeo-toolbox.org/jinglada/phenotb.git";
    ref = "master";
    rev = "85e991ab23695097ae59e034992695556fde5b2c";
  };

  otbBioVars = builtins.fetchGit {
    name = "otb-biovars";
    url = "https://gitlab.orfeo-toolbox.org/jinglada/otb-bv.git";
    ref = "master";
    rev = "519297118a6bbce819159e46432f83f4a5879d93";
  };

  otbGRM = builtins.fetchGit {
    name = "otb-GRM";
    url = "https://gitlab.irstea.fr/remi.cresson/GRM.git";
    ref = "master";
    rev = "0aca878d19c98d33fe7870ad9f37340235c6a0eb";
  };

  otbLSGRM = builtins.fetchGit {
    name = "otb-LSGRM";
    url = "https://gitlab.irstea.fr/remi.cresson/LSGRM.git";
    ref = "disassembled";
    rev = "52e1b0c0bd89eea2a94ac931a39da1b0e5a71833";
  };

  otbSeTools = builtins.fetchGit {
    name = "otb-simpleextractiontools";
    url = "https://forgemia.inra.fr/orfeo-toolbox/otb-simpleextractiontools.git";
    ref = "master";
    rev = "caad8a1b7a5858638c13e01866bbb45a9e2a87e5";
  };

  otbTempGapfill = builtins.fetchGit {
    name = "otb-temporalgapfilling";
    url = "https://gitlab.orfeo-toolbox.org/jinglada/temporalgapfilling.git";
    ref = "master";
    rev = "88e4e4254f17e51e908f622d364826da9c367a95";
  };

  otbTsUtils = builtins.fetchGit {
    name = "otb-timeseriesutils";
    url = "https://gitlab.irstea.fr/remi.cresson/TimeSeriesUtils.git";
    ref = "master";
    rev = "f0da48e07f9d09b2081cb6bdcbfcb4d189d38051";
  };

  otbTsSmooth = builtins.fetchGit {
    name = "otb-temporalsmoothing";
    url = "https://gitlab.irstea.fr/remi.cresson/TemporalSmoothing.git";
    ref = "master";
    rev = "15d0d710c3fe88a723e52c4ccc6c03fc7f669a0d";
  };
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
