build_docker:
	nix run .\#otb-docker.copyToDockerDaemon

build_dev_docker:
	nix run .\#otb-dev-docker.copyToDockerDaemon

#build_docker_arch64:
#	nix run .\#otb-docker-aarch64.copyToDockerDaemon