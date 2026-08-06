# =============================================================================
# Keybindings
# =============================================================================
#
# Configures Fish shell keyboard behavior and shortcuts.
#

# =============================================================================
# Vi Mode
# =============================================================================

# Enable Vi-style keybindings.
# Provides Normal and Insert modes similar to Vim.
fish_vi_key_bindings

# =============================================================================
# Insert Mode Shortcuts
# =============================================================================

# Accept the current autosuggestion.
# Inserts the suggested command from Fish history.
bind -M insert ctrl-space accept-autosuggestion

# Navigate command history by matching the current input.
# Searches backward and forward through previous commands.
bind -M insert ctrl-p history-search-backward
bind -M insert ctrl-n history-search-forward

# Open the interactive history search pager.
# Allows searching and selecting previous commands.
bind -M insert ctrl-r history-pager

