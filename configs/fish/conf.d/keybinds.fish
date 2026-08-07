# =============================================================================
# Keybindings
# =============================================================================
# Configure Fish keybindings and keyboard shortcuts.
# =============================================================================

# =============================================================================
# Vi Mode
# =============================================================================

# Enable Vim-style editing with Normal and Insert modes.
fish_vi_key_bindings

# =============================================================================
# Insert Mode Shortcuts
# =============================================================================

# Accept the current autosuggestion.
bind -M insert ctrl-space accept-autosuggestion

# Search command history for entries matching the current input.
bind -M insert ctrl-p history-search-backward
bind -M insert ctrl-n history-search-forward

# Open the interactive command history browser.
bind -M insert ctrl-r history-pager

