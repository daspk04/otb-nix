#  This module includes code from the OTB remote module otbtf
#   Copyright 2018-2019 Rémi Cresson (IRSTEA)
#   Copyright 2020-2025 Rémi Cresson (INRAE)
#  https://forgemia.inra.fr/orfeo-toolbox/otbtf/-/blob/develop/LICENSE
{pkgs, fetchFromGitLab, ...}:
fetchFromGitLab {
    owner = "orfeo-toolbox";
    repo = "otbtf";
    rev = "5.0.0";
    hash = "sha256-XVE4b6gc9HBT49ztms0DbkKu22qrhGUK0tU+MU2jDao=";
    domain = "forgemia.inra.fr";
}
