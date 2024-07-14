{ lib
, boost
, cmake
, fetchgit
, openssl
, stdenv
, enableOpenMP ? false
, pkgs
, ...
}:
let
  versionMeta = builtins.fromJSON (builtins.readFile ./version.json);
in
stdenv.mkDerivation rec {
  pname = "shark";
  # fetch the latest master, differs from otb superbuild which was last updated 2 years back
  version = versionMeta.version;

  src = builtins.fetchGit {
    name = pname;
    url = "https://github.com/Shark-ML/Shark";
    ref = "master";
    rev = versionMeta.rev;
  };

  # todo: check if patches are needed for nix
  # https://gitlab.orfeo-toolbox.org/orfeotoolbox/otb/-/tree/develop/SuperBuild/patches/SHARK?ref_type=heads
  # patch of hdf5 seems to be not needed based on latest master branch of shark-ml as HDF5 has been removed
  # c.f https://github.com/Shark-ML/Shark/commit/221c1f2e8abfffadbf3c5ef7cf324bc6dc9b4315
  patches = [
    #        ./shark-1-disable-hdf5-all.diff
    ./shark-2-ext-num-literals-all.diff
  ];

  # https://gitlab.orfeo-toolbox.org/orfeotoolbox/otb/-/blob/develop/SuperBuild/CMake/External_shark.cmake?ref_type=heads
  cmakeFlags =
    [
      "-DBUILD_SHARED_LIBS=ON"
      "-DBUILD_EXAMPLES=OFF"
      "-DBUILD_DOCS=OFF"
      "-DBUILD_TESTING=OFF"
      #      "-DENABLE_HDF5=OFF" no more needed based on latest master
      "-DENABLE_CBLAS=OFF"
    ]
    ++ lib.optionals (!enableOpenMP) [
      "-DENABLE_OPENMP=OFF"
    ];
  buildInputs = [
    boost
    openssl
  ];

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "The Shark Machine Leaning Library";
    homepage = "https://shark-ml.github.io/Shark/";
  };
}
