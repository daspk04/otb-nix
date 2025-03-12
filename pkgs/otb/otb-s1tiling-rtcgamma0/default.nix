#  This module includes code from the OTB remote module otb-s1-tiling
#  Copyright 2020-2023 (c) CS GROUP.
#  Copyright 2024 (c) CNES.
#  https://gitlab.orfeo-toolbox.org/s1-tiling/rtc_gamma0/-/blob/main/LICENSE
{pkgs, fetchFromGitLab, ...}:
fetchFromGitLab {
  owner = "s1-tiling";
  repo = "rtc_gamma0";
  rev = "1.0.2";
  hash = "sha256-Se9kcI/DRCfwi8xB0NnUM3RNBvVvGp8rA5N3hAEarzc=";
  domain = "gitlab.orfeo-toolbox.org";
}
