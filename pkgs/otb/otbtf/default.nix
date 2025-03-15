#  This module includes code from the OTB remote module otbtf
#   Copyright 2018-2019 Rémi Cresson (IRSTEA)
#   Copyright 2020-2021 Rémi Cresson (INRAE)
#  https://forgemia.inra.fr/orfeo-toolbox/otbtf/-/blob/develop/LICENSE
{pkgs, fetchFromGitLab, ...}:
fetchFromGitLab {
    owner = "orfeo-toolbox";
    repo = "otbtf";
    rev = "5.0.0rc4";
    hash = "sha256-OpiotQvFEYiYpY2ZCjF4zOnN+mTE4oof913BXBgfDAE=";
    domain = "forgemia.inra.fr";
}
