#!/bin/sh
set -eu

NIX_DIR="$HOME/.nix"
REPO_URL="https://github.com/aayanmohammad/nix.git"
MACHINE="/etc/nix/machine.nix"
CONF="/etc/nix/nix.conf"

SUDO_KEEPALIVE_PID=""

die() {
	echo "Error: $*" >&2
	exit 1
}

cleanup() {
	if [ -n "$SUDO_KEEPALIVE_PID" ]; then
		kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
	fi
}

request_sudo() {
	command -v sudo >/dev/null 2>&1 ||
		die "sudo is required but was not found."

	echo "Requesting sudo access..."
	sudo -v

	(
		while true; do
			sleep 60
			sudo -n true || exit
		done
	) &

	SUDO_KEEPALIVE_PID=$!
}

load_nix() {
	if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
		. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
	fi
}

install_nix() {
	if command -v nix >/dev/null 2>&1; then
		echo "Nix is already installed."
		return
	fi

	echo "Installing Nix..."

	curl -L https://nixos.org/nix/install |
		sh -s -- --daemon --yes

	load_nix

	command -v nix >/dev/null 2>&1 ||
		die "Nix was installed but could not be found in PATH."
}

ensure_nix_available() {
	if ! command -v nix >/dev/null 2>&1; then
		load_nix
	fi

	command -v nix >/dev/null 2>&1 ||
		die "Nix could not be loaded."
}

enable_flakes() {
	if grep -Eq '^[[:space:]]*experimental-features[[:space:]]*=' "$CONF" 2>/dev/null; then
		echo "Nix flakes are already configured."
		return
	fi

	echo "Enabling flakes..."

	printf '%s\n' \
		"experimental-features = nix-command flakes" |
		sudo tee -a "$CONF" >/dev/null
}

clone_configuration() {
	if [ -e "$NIX_DIR" ]; then
		echo "Removing existing configuration..."
		rm -rf "$NIX_DIR"
	fi

	echo "Cloning configuration..."

	nix shell nixpkgs#git -c \
		git clone "$REPO_URL" "$NIX_DIR"
}

detect_system() {
	OS="$(uname -s)"
	ARCH="$(uname -m)"

	case "$OS" in
	Linux)
		NIX_OS="linux"
		;;

	Darwin)
		NIX_OS="darwin"
		;;

	*)
		die "Unsupported operating system: $OS"
		;;
	esac

	case "$ARCH" in
	x86_64)
		NIX_ARCH="x86_64"
		;;

	aarch64 | arm64)
		NIX_ARCH="aarch64"
		;;

	*)
		die "Unsupported architecture: $ARCH"
		;;
	esac
}

generate_machine_config() {
	if [ -e "$MACHINE" ]; then
		echo "machine.nix already exists."
		cat "$MACHINE"
		return
	fi

	echo "Generating machine.nix..."

	sudo tee "$MACHINE" >/dev/null <<EOF
{
  system = "${NIX_ARCH}-${NIX_OS}";
  username = "$USER";
  homeDirectory = "$HOME";
}
EOF

	sudo chmod 644 "$MACHINE"
	cat "$MACHINE"
}

apply_home_manager() {
	echo "Applying Home Manager..."

	(
		cd "$NIX_DIR"
		nix run home-manager -- switch --flake ".#$USER"
	)
}

configure_fish() {
	fish_path="$(command -v fish || true)"

	if [ -z "$fish_path" ]; then
		die "Fish was not found after applying the Home Manager configuration."
	fi

	if [ ! -f /etc/shells ] || ! grep -Fxq "$fish_path" /etc/shells; then
		echo "Adding Fish to /etc/shells..."
		echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
	fi

	current_shell="${SHELL:-}"

	if [ "$current_shell" != "$fish_path" ]; then
		echo "Changing login shell to Fish..."
		sudo chsh -s "$fish_path" "$USER"
	else
		echo "Fish is already the login shell."
	fi
}

main() {
	request_sudo

	install_nix
	ensure_nix_available

	enable_flakes
	clone_configuration

	detect_system
	generate_machine_config

	apply_home_manager
	configure_fish

	echo
	echo "Done."
}

trap cleanup EXIT HUP INT TERM

main "$@"

