#  This module includes code from the OTB remote module otbtf
#   Copyright 2018-2019 Rémi Cresson (IRSTEA)
#   Copyright 2020-2025 Rémi Cresson (INRAE)
#  https://forgemia.inra.fr/orfeo-toolbox/otbtf/-/blob/develop/LICENSE
{pkgs, fetchFromGitLab, ...}:
fetchFromGitLab {
    owner = "orfeo-toolbox";
    repo = "otbtf";
    rev = "5.0.0";
    hash = "sha256-6VqjuydvTmP+ES6xLQ8uSGTw/+ynYui+QkGXerYkZX8=";
    domain = "forgemia.inra.fr";
}
