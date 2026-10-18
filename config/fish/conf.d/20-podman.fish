# Point docker-API clients (lazydocker, etc.) at rootless podman when its socket exists.
# Respect an explicit DOCKER_HOST (e.g. set in local.fish).
set -q DOCKER_HOST; and exit
set -l sock $XDG_RUNTIME_DIR/podman/podman.sock
test -S $sock; and set -gx DOCKER_HOST unix://$sock
