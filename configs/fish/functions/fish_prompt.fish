# =============================================================================
# Fish Prompt
# =============================================================================
# Minimal Fish prompt with transient prompt support
#
# Normal prompt format:
# user@host | ~/current/path - branch (↑↓*)
#
# Git indicators:
# ↑  Local branch ahead of upstream (not yet pushed)
# ↓  Local branch behind upstream (pull/fetch needed)
# *  Working tree contains uncommitted or untracked changes

# Show the full working directory (disable path shortening)
set -g fish_prompt_pwd_dir_length 0

# Replace previous prompts with a minimal prompt after each command
set -g fish_transient_prompt 1

# -----------------------------------------------------------------------------
# Prompt Colors
# -----------------------------------------------------------------------------

set -g __prompt_user_color green
set -g __prompt_sep_color brblack
set -g __prompt_pwd_color blue
set -g __prompt_git_color yellow
set -g __prompt_flag_color red
set -g __prompt_insert_color green
set -g __prompt_normal_color red

# -----------------------------------------------------------------------------
# Git Information
# -----------------------------------------------------------------------------

function __git_prompt_info
    # Run Git once and parse the output instead of multiple Git commands
    set -l git_data (command git status --porcelain=2 --branch 2>/dev/null)
    or return

    # Current branch name
    set -l branch (
        string match -r '^# branch.head .*' $git_data \
        | string replace '# branch.head ' ''
    )

    # Show abbreviated commit hash when HEAD is detached
    if test "$branch" = "(detached)"
        set branch (
            string match -r '^# branch.oid .*' $git_data \
            | string replace '# branch.oid ' '' \
            | string sub -l 7
        )
    end

    set -l flags

    # Local branch is ahead of its upstream
    string match -qr '^# branch.ab .*?\+[1-9]' -- $git_data
    and set flags "$flags↑"

    # Local branch is behind its upstream
    string match -qr '^# branch.ab .*?-[1-9]' -- $git_data
    and set flags "$flags↓"

    # Repository has uncommitted, untracked, or conflicted changes
    string match -qr '^[12u?]' -- $git_data
    and set flags "$flags*"

    printf "%s\t%s" "$branch" "$flags"
end

# -----------------------------------------------------------------------------
# Main Prompt
# -----------------------------------------------------------------------------

function fish_prompt
    # During transient rendering, replace previous prompt with a simple marker
    if contains -- --final-rendering $argv
        printf "> "
        return
    end

    # User and host
    set_color $__prompt_user_color
    printf "%s@%s" $USER (prompt_hostname)

    # Separator
    set_color $__prompt_sep_color
    printf " | "

    # Current working directory
    set_color $__prompt_pwd_color
    printf "%s" (prompt_pwd)

    # Git branch and repository status
    set -l git (__git_prompt_info)

    if test -n "$git"
        set -l parts (string split \t $git)
        set -l branch $parts[1]
        set -l flags $parts[2]

        set_color $__prompt_sep_color
        printf " - "

        set_color $__prompt_git_color
        printf "%s" "$branch"

        if test -n "$flags"
            set_color $__prompt_flag_color
            printf " (%s)" "$flags"
        end
    end

    # Restore default terminal colors before starting the next line
    set_color normal
    printf "\n"

    # Show the current vi editing mode
    if test "$fish_bind_mode" = insert
        set_color $__prompt_insert_color
        printf "> "
    else
        set_color $__prompt_normal_color
        printf "< "
    end

    # Restore default terminal colors
    set_color normal
end

