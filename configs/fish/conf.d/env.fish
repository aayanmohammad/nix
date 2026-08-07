# =============================================================================
# Environment
# =============================================================================
# Configure environment variables and other settings shared by all sessions
# =============================================================================

# =============================================================================
# Fish Configuration
# =============================================================================

# Disable the default Fish welcome message
set -g fish_greeting

# =============================================================================
# Default Editor
# =============================================================================

# Use Neovim as the default text editor
set -gx EDITOR (command -v nvim)
set -gx VISUAL $EDITOR

# =============================================================================
# Nix
# =============================================================================

# Add the user Nix profile to PATH
fish_add_path ~/.nix-profile/bin

# Load the Nix daemon environment when available
if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end

