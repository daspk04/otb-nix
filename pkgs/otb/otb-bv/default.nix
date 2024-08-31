#  This module includes code from the OTB remote module otb-bv
#  Copyright Jordi Inglada
#  https://gitlab.orfeo-toolbox.org/jinglada/otb-bv/-/blob/master/otb-bv-copyright.txt
{pkgs, ...}:
builtins.fetchGit {
  name = "otb-biovars";
  url = "https://gitlab.orfeo-toolbox.org/jinglada/otb-bv.git";
  ref = "master";
  rev = "519297118a6bbce819159e46432f83f4a5879d93";
}
