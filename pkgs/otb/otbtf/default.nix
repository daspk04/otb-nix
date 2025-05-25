#  This module includes code from the OTB remote module otbtf
#   Copyright 2018-2019 Rémi Cresson (IRSTEA)
#   Copyright 2020-2025 Rémi Cresson (INRAE)
#  https://forgemia.inra.fr/orfeo-toolbox/otbtf/-/blob/develop/LICENSE
{pkgs, fetchFromGitHub, ...}:
fetchFromGitHub {
    owner = "remicres";
    repo = "otbtf";
    tag = "5.0.0";
    hash = "sha256-/UIQpaXJgQq3JOzibWHBlMqlBdp6lcNmMOv7hO0J2w4=";
}
