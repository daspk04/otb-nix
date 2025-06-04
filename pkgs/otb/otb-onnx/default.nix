#  This module includes code from the OTB remote module otb-onnx
#  Copyright 2024 Rémi Cresson (INRAE)
#  https://forgemia.inra.fr/orfeo-toolbox/otbonnx/-/blob/alpha/LICENSE
{pkgs, fetchFromGitLab, ...}:
fetchFromGitLab {
    owner = "orfeo-toolbox";
    repo = "otbonnx";
    rev = "d715a47dec4b341a5fbaa899ea01013d23f521d5";
    hash = "sha256-DpVtZTSTZSHttJ3Z+VlGqZ7H6/VAjXJdGQgod3gIFvQ=";
    domain = "forgemia.inra.fr";
}