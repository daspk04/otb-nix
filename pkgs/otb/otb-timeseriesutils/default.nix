#   This module includes code from the OTB remote module TimeSeriesUtils
#   Copyright Rémi Cresson (IRSTEA)
#   https://gitlab.irstea.fr/remi.cresson/TimeSeriesUtils/-/blob/master/LICENSE
{pkgs, ...}:
builtins.fetchGit {
  name = "otb-timeseriesutils";
  url = "https://gitlab.irstea.fr/remi.cresson/TimeSeriesUtils.git";
  ref = "master";
  rev = "f0da48e07f9d09b2081cb6bdcbfcb4d189d38051";
}
