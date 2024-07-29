{
  nix2containerPkgs,
  python3,
  otb,
  img-name ? "otb",
  img-tag ? "latest",
  extra-packages ? [],
  extra-python-packages ? [],
  pkgs,
  ...
}: let
  py-env = (
    python3.withPackages (pp:
      with pp;
        [numpy]
        ++ extra-python-packages)
  );

  py-env-sitepackages = "${py-env}/${py-env.sitePackages}";
  py-env-bin = "${py-env}/bin";
  otbLibPath = with pkgs; pkgs.lib.makeLibraryPath [otb];
  otbBinPath = with pkgs; pkgs.lib.makeBinPath otb.propagatedBuildInputs;
in
  nix2containerPkgs.nix2container.buildImage rec {
    name = img-name;
    tag = img-tag;

    copyToRoot = pkgs.buildEnv {
      name = "root";
      paths = with pkgs.dockerTools;
      with pkgs;
        [
          # Base OS
          ## GNU
          coreutils-full
          findutils
          bashInteractive
          gnugrep
          gnused
          which

          ## Networking
          cacert
          caCertificates
          fakeNss
          shadowSetup
          iana-etc

          # Conveniences
          git
          neovim-unwrapped
          zsh

          # Library
          otb
          py-env
        ]
        ++ extra-packages;

      pathsToLink = ["/bin" "/etc" "/var" "/run" "/tmp" "/lib"];
      postBuild = ''
        mkdir -p $out/tmp
        mkdir -p $out/etc
        cat <<HEREDOC > $out/etc/zshrc
        autoload -U compinit && compinit
        autoload -U promptinit && promptinit && prompt suse && setopt prompt_sp
        autoload -U colors && colors
        export PS1=$'%{\033[31m%}[nix-shell:%{\033[32m%}%~%{\033[31m%}]%{\033[0m%}$ ';
        HEREDOC
      '';
    };

    config = {
      Cmd = ["/bin/env" "zsh"];
      Env = [
        "LANG=C.UTF-8"
        "LC_ALL=C.UTF-8"
        "LC_CTYPE=C.UTF-8"
        "EDITOR=nvim"
        "PYTHONPATH=${py-env-sitepackages}:${otbLibPath}/otb/python"
        "PATH=${py-env-bin}:${otbBinPath}:/bin"
        "TMPDIR=/tmp"
      ];
    };
  }

