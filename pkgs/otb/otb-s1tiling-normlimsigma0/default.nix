#  This module includes code from the OTB remote module otb-s1-tiling
#  Copyright (C) 2005-2025 Centre National d'Etudes Spatiales (CNES)
#  https://gitlab.orfeo-toolbox.org/s1-tiling/normlim_sigma0/-/blob/master/LICENSE
{pkgs, fetchFromGitLab, ...}:
fetchFromGitLab {
  owner = "s1-tiling";
  repo = "normlim_sigma0";
  rev = "1.2.1";
  hash = "sha256-JWxyDwIIlFFkVKUTIilsKwRn19R3LjszjYFiwBVMPpE=";
  domain = "gitlab.orfeo-toolbox.org";

}
