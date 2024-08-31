#  This module includes code from the OTB remote module LSGRM
#  Copyright (c) Centre National d'Etudes Spatiales
#  author: Pierre Lassalle
#  additional contributors: Remi Cresson, Raffaele Gaetano
#  https://gitlab.irstea.fr/remi.cresson/LSGRM/-/blob/master/grmlib-copyright.txt
{pkgs, ...}:
builtins.fetchGit {
  name = "otb-LSGRM";
  url = "https://gitlab.irstea.fr/remi.cresson/LSGRM.git";
  ref = "disassembled";
  rev = "52e1b0c0bd89eea2a94ac931a39da1b0e5a71833";
}
