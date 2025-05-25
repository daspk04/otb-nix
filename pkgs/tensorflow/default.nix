# tensorflow package patched with missing header files, required for building otbtf tensorflow module
{
  pkgs,
  python,
  tensorflow,
  fetchFromGitHub,
  ...
}:
let
  tfVersion = tensorflow.version;
  hashInfo = import ./source-hashes.nix tfVersion;

  tfSrc = fetchFromGitHub {
    owner = "tensorflow";
    repo = "tensorflow";
    rev = "v${tfVersion}";
    hash = hashInfo.gitHash;
  };
in
tensorflow.overrideAttrs (oldAttrs: {
  postInstall =
    oldAttrs.postInstall or ""
    + ''
      mkdir -p $out/${python.sitePackages}/tensorflow/include/tensorflow/cc/saved_model/
      cp ${tfSrc}/tensorflow/cc/saved_model/tag_constants.h \
         $out/${python.sitePackages}/tensorflow/include/tensorflow/cc/saved_model/
      cp ${tfSrc}/tensorflow/cc/saved_model/signature_constants.h \
         $out/${python.sitePackages}/tensorflow/include/tensorflow/cc/saved_model/
    '';
})