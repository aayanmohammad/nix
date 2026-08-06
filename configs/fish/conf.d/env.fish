# =============================================================================
# Environment Variables
# =============================================================================

# =============================================================================
# Fish Configuration
# =============================================================================

# Disable the default Fish welcome message.
set -g fish_greeting

# =============================================================================
# Default Editor
# =============================================================================

# Set Neovim as the default command-line editor.
set -gx EDITOR nvim
set -gx VISUAL nvim

# =============================================================================
# Nix
# =============================================================================

# Add Nix profile binaries to PATH.
fish_add_path ~/.nix-profile/bin

# Enable Nix commands in shell
if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end

