#  This module includes code from the OTB remote module otbtf
#   Copyright 2018-2019 Rémi Cresson (IRSTEA)
#   Copyright 2020-2021 Rémi Cresson (INRAE)
#  https://forgemia.inra.fr/orfeo-toolbox/otbtf/-/blob/develop/LICENSE
{pkgs, ...}:
builtins.fetchGit {
  name = "otbtf";
  url = "https://forgemia.inra.fr/orfeo-toolbox/otbtf.git";
  ref = "refs/tags/r4.3.1";
  rev = "c9b02fb7d1ed5c28a45dc40dd15bfb4b59b77e95";
}
