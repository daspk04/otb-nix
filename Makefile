build_docker:
	nix run .\#otb-docker.copyToDockerDaemon

build_dev_docker:
	nix run .\#otb-dev-docker.copyToDockerDaemon

#build_docker_arch64:
#	nix run .\#otb-docker-aarch64.copyToDockerDaemon

.PHONY: bump_patch
bump_patch:
	bump-my-version bump patch

.PHONY: bump_minor
bump_minor:
	bump-my-version bump minor

.PHONY: bump_major
bump_major:
	bump-my-version bump major