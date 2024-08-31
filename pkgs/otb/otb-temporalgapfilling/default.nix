#  This module includes code from the OTB remote module temporalgapfilling
#  Copyright Jordi Inglada
#  https://gitlab.orfeo-toolbox.org/jinglada/temporalgapfilling/-/blob/master/LICENSE
{pkgs, ...}:
builtins.fetchGit {
  name = "otb-temporalgapfilling";
  url = "https://gitlab.orfeo-toolbox.org/jinglada/temporalgapfilling.git";
  ref = "master";
  rev = "88e4e4254f17e51e908f622d364826da9c367a95";
}
