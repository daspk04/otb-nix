#   This module includes code from the OTB remote module TemporalSmoothing
#   Copyright Rémi Cresson (IRSTEA)
#   https://gitlab.irstea.fr/remi.cresson/TemporalSmoothing/-/blob/master/LICENSE
{pkgs, ...}:
builtins.fetchGit {
  name = "otb-temporalsmoothing";
  url = "https://gitlab.irstea.fr/remi.cresson/TemporalSmoothing.git";
  ref = "master";
  rev = "15d0d710c3fe88a723e52c4ccc6c03fc7f669a0d";
}
