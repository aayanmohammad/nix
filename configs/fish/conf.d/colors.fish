# =============================================================================
# Gruvbox Dark Terminal Colors
# =============================================================================
#
# Configure terminal colors using OSC (Operating System Command) escape sequences
#
# This sets:
# - Default foreground color
# - Default background color
# - ANSI color palette (0–15)
#
# Requires a terminal emulator that supports OSC color sequences
# Applications that use terminal colors will automatically use this palette

# =============================================================================
# Default Colors
# =============================================================================

# Default background color
printf '\e]11;rgb:28/28/28\a'

# Default foreground color
printf '\e]10;rgb:eb/db/b2\a'

# =============================================================================
# ANSI Color Palette (0–15)
# =============================================================================

# Standard ANSI colors
#  0  Black
#  1  Red
#  2  Green
#  3  Yellow
#  4  Blue
#  5  Magenta
#  6  Cyan
#  7  White
printf '\e]4;0;rgb:28/28/28\a'
printf '\e]4;1;rgb:cc/24/1d\a'
printf '\e]4;2;rgb:98/97/1a\a'
printf '\e]4;3;rgb:d7/99/21\a'
printf '\e]4;4;rgb:45/85/88\a'
printf '\e]4;5;rgb:b1/62/86\a'
printf '\e]4;6;rgb:68/9d/6a\a'
printf '\e]4;7;rgb:a8/99/84\a'

# Bright ANSI colors
#  8  Bright Black
#  9  Bright Red
# 10  Bright Green
# 11  Bright Yellow
# 12  Bright Blue
# 13  Bright Magenta
# 14  Bright Cyan
# 15  Bright White
printf '\e]4;8;rgb:92/83/74\a'
printf '\e]4;9;rgb:fb/49/34\a'
printf '\e]4;10;rgb:b8/bb/26\a'
printf '\e]4;11;rgb:fa/bd/2f\a'
printf '\e]4;12;rgb:83/a5/98\a'
printf '\e]4;13;rgb:d3/86/9b\a'
printf '\e]4;14;rgb:8e/c0/7c\a'
printf '\e]4;15;rgb:eb/db/b2\a'

