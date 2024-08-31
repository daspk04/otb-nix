#   This module includes code from the OTB remote module GRM
#   Copyright (c) Centre National d'Études Spatiales
#   author: Lassalle Pierre
#   https://gitlab.irstea.fr/remi.cresson/GRM/-/tree/master/#licence
{pkgs, ...}:
builtins.fetchGit {
  name = "otb-GRM";
  url = "https://gitlab.irstea.fr/remi.cresson/GRM.git";
  ref = "master";
  rev = "0aca878d19c98d33fe7870ad9f37340235c6a0eb";
}
