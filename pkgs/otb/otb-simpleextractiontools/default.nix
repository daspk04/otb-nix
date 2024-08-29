#  This module includes code from the OTB remote module otb-simpleextractiontools
#  Copyright Rémi Cresson (IRSTEA)
#  https://forgemia.inra.fr/orfeo-toolbox/otb-simpleextractiontools/-/blob/master/LICENCE
{pkgs, ...}:
builtins.fetchGit {
  name = "otb-simpleextractiontools";
  url = "https://forgemia.inra.fr/orfeo-toolbox/otb-simpleextractiontools.git";
  ref = "master";
  rev = "caad8a1b7a5858638c13e01866bbb45a9e2a87e5";
}
