# tensorflow package patched with missing header files, required for building otbtf tensorflow module
{
  pkgs,
  python3,
  fetchFromGitHub,
  ...
}:
let
  tfSrc = fetchFromGitHub {
    owner = "tensorflow";
    repo = "tensorflow";
    tag = "v${python3.pkgs.tensorflow-bin.version}";
    hash = "sha256-/S//LZwWGJPoqoGalSntrPhd6NuGTl1VVmQm17bIwSs=";
  };
in
pkgs.python3Packages.tensorflow-bin.overrideAttrs (oldAttrs: {
  postInstall =
    oldAttrs.postInstall
    + ''
      echo "Patching TensorFlow to include missing header files..."
      mkdir -p $out/${python3.pkgs.python.sitePackages}/tensorflow/include/tensorflow/cc/saved_model/
      cp ${tfSrc}/tensorflow/cc/saved_model/tag_constants.h \
         $out/${python3.pkgs.python.sitePackages}/tensorflow/include/tensorflow/cc/saved_model/
      cp ${tfSrc}/tensorflow/cc/saved_model/signature_constants.h \
         $out/${python3.pkgs.python.sitePackages}/tensorflow/include/tensorflow/cc/saved_model/
      echo "TensorFlow patched successfully."
    '';
})
