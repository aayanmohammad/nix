# =============================================================================
# Aliases
# =============================================================================
#
# Common command shortcuts and safer defaults for interactive Fish sessions.

# =============================================================================
# Directory Listing
# =============================================================================

# Enable colored output for ls when supported.
alias ls "ls --color=auto"

# List all files except . and ..
# Includes hidden files such as .config and .gitignore.
alias la "ls -A"

# Display detailed file information with human-readable sizes.
# Shows permissions, ownership, size, and timestamps.
alias ll "ls -lAh"

# =============================================================================
# File Operations
# =============================================================================

# Copy files with verbose output.
# Displays each file or directory being copied.
alias cp "cp -v"

# Remove files with verbose output.
# Displays each file or directory being removed.
alias rm "rm -v"

