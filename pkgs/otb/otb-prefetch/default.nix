#  This module includes code from the OTB remote module otb-prefetch
#  Copyright 2024 Rémi Cresson (INRAE)
#  https://github.com/remicres/otb-prefetch/blob/main/LICENSE
{pkgs, ...}:
builtins.fetchGit {
  name = "otb-prefetch";
  url = "https://github.com/remicres/otb-prefetch.git";
  ref = "main";
  rev = "1faaa10d79e393bd45da95dde590f4857910c0ce";
}
