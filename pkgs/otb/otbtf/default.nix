#   This module includes code from the OTB remote module otb-mlutils
#   Copyright Rémi Cresson (IRSTEA)
#   https://forgemia.inra.fr/orfeo-toolbox/otb-mlutils/-/blob/master/LICENSE
{pkgs, ...}:
builtins.fetchGit {
  name = "otb-mlutils";
  url = "https://forgemia.inra.fr/orfeo-toolbox/otb-mlutils.git";
  ref = "master";
  rev = "4f6de3654b249de98d5d5fef9c4bf4b623280ce4";
}
