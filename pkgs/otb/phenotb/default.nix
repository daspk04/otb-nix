#  This module includes code from the OTB remote module otb-phenotb
#  Copyright Jordi Inglada
#  https://gitlab.orfeo-toolbox.org/jinglada/phenotb/-/blob/master/LICENSE
{pkgs, ...}:
builtins.fetchGit {
  name = "otb-phenology";
  url = "https://gitlab.orfeo-toolbox.org/jinglada/phenotb.git";
  ref = "master";
  rev = "85e991ab23695097ae59e034992695556fde5b2c";
}
