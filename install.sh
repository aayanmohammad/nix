#!/bin/sh
set -eu

REPO_URL="https://github.com/aayanmohammad/nix.git"
NIX_DIR="$HOME/.nix"

#######################################
# Require sudo
#######################################

require_sudo() {
	if ! command -v sudo >/dev/null 2>&1; then
		echo "sudo is required but was not found."
		exit 1
	fi

	echo "Requesting sudo access..."
	sudo -v

	while true; do
		sudo -n true
		sleep 60
		kill -0 "$$" 2>/dev/null || exit
	done 2>/dev/null &
}

#######################################
# Existing install
#######################################

check_existing() {
	if [ -e "$NIX_DIR" ]; then
		echo "Existing Nix configuration found at:"
		echo "$NIX_DIR"

		printf "Replace it and reinstall? [y/N] "
		read -r answer </dev/tty

		case "$answer" in
		y | Y)
			echo "Removing existing configuration..."
			rm -rf "$NIX_DIR"
			;;
		*)
			echo "Cancelled - no changes have occurred."
			exit 0
			;;
		esac
	fi
}

#######################################
# Install Nix
#######################################

install_nix() {
	if [ -d /etc/nix ]; then
		echo "Nix detected."
		command -v nix || true
		return
	fi

	echo "Installing Nix..."
	curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes
}

#######################################
# Load Nix
#######################################

load_nix() {
	if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
		echo "Loading Nix..."
		. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
	fi
}

#######################################
# Enable flakes
#######################################

enable_flakes() {
	CONF="/etc/nix/nix.conf"

	if ! grep -q "experimental-features" "$CONF" 2>/dev/null; then
		echo "Enabling flakes..."

		echo "experimental-features = nix-command flakes" |
			sudo tee -a "$CONF" >/dev/null
	fi
}

#######################################
# Clone repo using temporary git
#######################################

clone_repo() {
	echo "Cloning configuration..."

	nix shell nixpkgs#git -c \
		git clone "$REPO_URL" "$NIX_DIR"
}

#######################################
# Generate machine config
#######################################

create_machine() {
	MACHINE="/etc/nix/machine.nix"

	echo "Generating machine.nix..."

	sudo tee "$MACHINE" >/dev/null <<EOF
{
  system = "$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]')";
  username = "$USER";
  homeDirectory = "$HOME";
}
EOF

	sudo chmod 644 "$MACHINE"

	cat "$MACHINE"
}

#######################################
# First activation
#######################################

first_run() {

	echo "Applying Home Manager..."

	cd "$NIX_DIR"

	nix run home-manager -- switch --flake ".#$USER"

	cd -
}

#######################################
# Fish
#######################################

setup_fish() {
	echo "Enabling Fish..."

	if command -v fish >/dev/null 2>&1; then
		sudo chsh -s "$(command -v fish)"
	fi
}

#######################################
# Main
#######################################

main() {
	require_sudo

	check_existing

	install_nix

	load_nix

	enable_flakes

	clone_repo

	create_machine

	first_run

	setup_fish

	echo
	echo "Done."
}

main

