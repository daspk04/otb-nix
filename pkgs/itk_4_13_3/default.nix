{
  lib,
  stdenv,
  fetchgit,
  cmake,
  expat,
  fftw,
  fftwFloat,
  gdcm,
  hdf5-cpp,
  libjpeg,
  libminc,
  libtiff,
  libpng,
  libuuid,
  xz,
  vtk,
  zlib,
  ...
}: let
  versionMeta = builtins.fromJSON (builtins.readFile ./version.json);
in
  stdenv.mkDerivation rec {
    pname = "itk";
    version = versionMeta.version;

    src = builtins.fetchGit {
      name = pname;
      url = "https://github.com/InsightSoftwareConsortium/ITK";
      # version is same as OTB Superbuild
      # https://gitlab.orfeo-toolbox.org/orfeotoolbox/otb/-/blob/develop/SuperBuild/CMake/External_itk.cmake?ref_type=heads#L149
      ref = "refs/tags/v${version}";
      rev = versionMeta.rev;
    };

    # https://gitlab.orfeo-toolbox.org/orfeotoolbox/otb/-/tree/develop/SuperBuild/patches/ITK?ref_type=heads
    # todo: check if all the patches are required for nix
    patches = [
      #./itk-1-fftw-all-diff
      ./itk-2-itktestlib-all.diff
      ./itk-3-remove-gcc-version-debian-medteam-all.diff
    ];

    # https://gitlab.orfeo-toolbox.org/orfeotoolbox/otb/-/blob/develop/SuperBuild/CMake/External_itk.cmake?ref_type=heads
    cmakeFlags = [
      "-DBUILD_TESTING=OFF"
      "-DBUILD_EXAMPLES=OFF"
      "-DBUILD_SHARED_LIBS=ON"
      "-DITK_BUILD_DEFAULT_MODULES=OFF"
      "-DITKGroup_Core=OFF"
      "-DITK_FORBID_DOWNLOADS=ON"
      "-DITK_USE_SYSTEM_LIBRARIES=ON" # finds common libraries e.g. hdf5, libpng, libtiff, libjpeg, zlib etc
      #   "-DITK_USE_KWSTYLE=OFF"
      # todo: check if this needs to be enabled as nixpkgs for ITK 5.2.X has this disabled
      "-DITK_USE_SYSTEM_EIGEN=OFF"
      #  "-DITK_USE_SYSTEM_EXPAT=ON"
      #  "-DITK_USE_SYSTEM_ZLIB=ON"
      #  "-DITK_USE_SYSTEM_TIFF=ON"
      #  "-DITK_USE_SYSTEM_PNG=ON"
      "-DModule_ITKCommon=ON"
      #"-DModule_ITKTestKernel=ON"
      "-DModule_ITKFiniteDifference=ON"
      "-DModule_ITKGPUCommon=ON"
      "-DModule_ITKGPUFiniteDifference=ON"
      "-DModule_ITKImageAdaptors=ON"
      "-DModule_ITKImageFunction=ON"
      "-DModule_ITKMesh=ON"
      "-DModule_ITKQuadEdgeMesh=ON"
      "-DModule_ITKSpatialObjects=ON"
      "-DModule_ITKTransform=ON"
      "-DModule_ITKTransformFactory=ON"
      "-DModule_ITKIOTransformBase=ON"
      "-DModule_ITKIOTransformInsightLegacy=ON"
      "-DModule_ITKIOTransformMatlab=ON"
      "-DModule_ITKAnisotropicSmoothing=ON"
      "-DModule_ITKAntiAlias=ON"
      "-DModule_ITKBiasCorrection=ON"
      "-DModule_ITKBinaryMathematicalMorphology=ON"
      "-DModule_ITKColormap=ON"
      "-DModule_ITKConvolution=ON"
      "-DModule_ITKCurvatureFlow=ON"
      "-DModule_ITKDeconvolution=ON"
      "-DModule_ITKDenoising=ON"
      #-DModule_ITKDiffusionTensorImage=ON
      "-DModule_ITKDisplacementField=ON"
      "-DModule_ITKDistanceMap=ON"
      "-DModule_ITKFastMarching=ON"
      "-DModule_ITKFFT=ON"
      "-DModule_ITKGPUAnisotropicSmoothing=ON"
      "-DModule_ITKGPUImageFilterBase=ON"
      "-DModule_ITKGPUSmoothing=ON"
      "-DModule_ITKGPUThresholding=ON"
      "-DModule_ITKImageCompare=ON"
      "-DModule_ITKImageCompose=ON"
      "-DModule_ITKImageFeature=ON"
      "-DModule_ITKImageFilterBase=ON"
      "-DModule_ITKImageFusion=ON"
      "-DModule_ITKImageGradient=ON"
      "-DModule_ITKImageGrid=ON"
      "-DModule_ITKImageIntensity=ON"
      "-DModule_ITKImageLabel=ON"
      "-DModule_ITKImageSources=ON"
      "-DModule_ITKImageStatistics=ON"
      "-DModule_ITKLabelMap=ON"
      "-DModule_ITKMathematicalMorphology=ON"
      "-DModule_ITKPath=ON"
      "-DModule_ITKQuadEdgeMeshFiltering=ON"
      "-DModule_ITKSmoothing=ON"
      "-DModule_ITKSpatialFunction=ON"
      "-DModule_ITKThresholding=ON"
      "-DModule_ITKEigen=ON"
      #"-DModule_ITKFEM=ON"
      "-DModule_ITKNarrowBand=ON"
      "-DModule_ITKNeuralNetworks=ON"
      "-DModule_ITKOptimizers=ON"
      "-DModule_ITKOptimizersv4=ON"
      "-DModule_ITKPolynomials=ON"
      "-DModule_ITKStatistics=ON"
      "-DModule_ITKRegistrationCommon=ON"
      #"-DModule_ITKFEMRegistration=ON"
      "-DModule_ITKGPURegistrationCommon=ON"
      "-DModule_ITKGPUPDEDeformableRegistration=ON"
      "-DModule_ITKMetricsv4=ON"
      "-DModule_ITKPDEDeformableRegistration=ON"
      "-DModule_ITKRegistrationMethodsv4=ON"
      #"-DModule_ITKBioCell=ON"
      "-DModule_ITKClassifiers=ON"
      "-DModule_ITKConnectedComponents=ON"
      "-DModule_ITKDeformableMesh=ON"
      "-DModule_ITKKLMRegionGrowing=ON"
      "-DModule_ITKLabelVoting=ON"
      "-DModule_ITKLevelSets=ON"
      "-DModule_ITKLevelSetsv4=ON"
      #"-DModule_ITKLevelSetsv4Visualization=ON"
      "-DModule_ITKMarkovRandomFieldsClassifiers=ON"
      "-DModule_ITKRegionGrowing=ON"
      "-DModule_ITKSignedDistanceFunction=ON"
      "-DModule_ITKVoronoi=ON"
      "-DModule_ITKWatersheds=ON"
    ];

    nativeBuildInputs = [cmake xz];
    buildInputs = [
      libuuid
    ];
    propagatedBuildInputs = [
      # The dependencies we've un-vendored from ITK, must be propagated,
      # otherwise other software built against ITK fails to configure since ITK headers
      # refer to these previously vendored libraries:
      expat
      fftw
      fftwFloat
      hdf5-cpp
      libjpeg
      libpng
      libtiff
      zlib
    ];

    meta = {
      description = "Insight Segmentation and Registration Toolkit";
      homepage = "https://www.itk.org";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [daskpk04];
    };
  }
