# =============================================================================
# Gruvbox Dark Colors
# =============================================================================
#
# Sets the terminal emulator colors using OSC escape sequences.
#
# This configures:
#   - Default foreground color
#   - Default background color
#   - ANSI color palette (0-15)
#
# Requires a terminal emulator with OSC color support.
# These settings affect applications that use terminal colors.

# =============================================================================
# Default Colors
# =============================================================================

# Background color
printf '\e]11;rgb:28/28/28\a'

# Foreground color
printf '\e]10;rgb:eb/db/b2\a'

# =============================================================================
# ANSI Color Palette (0-15)
# =============================================================================
#
# Standard colors:
#   0  Black
#   1  Red
#   2  Green
#   3  Yellow
#   4  Blue
#   5  Magenta
#   6  Cyan
#   7  White
#
# Bright colors:
#   8  Bright Black
#   9  Bright Red
#   10 Bright Green
#   11 Bright Yellow
#   12 Bright Blue
#   13 Bright Magenta
#   14 Bright Cyan
#   15 Bright White

# Normal colors
printf '\e]4;0;rgb:28/28/28\a'# Black
printf '\e]4;1;rgb:cc/24/1d\a' # Red
printf '\e]4;2;rgb:98/97/1a\a' # Green
printf '\e]4;3;rgb:d7/99/21\a' # Yellow
printf '\e]4;4;rgb:45/85/88\a' # Blue
printf '\e]4;5;rgb:b1/62/86\a' # Magenta
printf '\e]4;6;rgb:68/9d/6a\a' # Cyan
printf '\e]4;7;rgb:a8/99/84\a' # White

# Bright colors
printf '\e]4;8;rgb:92/83/74\a' # Bright Black
printf '\e]4;9;rgb:fb/49/34\a' # Bright Red
printf '\e]4;10;rgb:b8/bb/26\a' # Bright Green
printf '\e]4;11;rgb:fa/bd/2f\a' # Bright Yellow
printf '\e]4;12;rgb:83/a5/98\a' # Bright Blue
printf '\e]4;13;rgb:d3/86/9b\a' # Bright Magenta
printf '\e]4;14;rgb:8e/c0/7c\a' # Bright Cyan
printf '\e]4;15;rgb:eb/db/b2\a' # Bright White

