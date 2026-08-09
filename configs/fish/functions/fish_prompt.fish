set -g fish_prompt_pwd_dir_length 0

set -g fish_transient_prompt 1

set -g __prompt_user_color green
set -g __prompt_sep_color brblack
set -g __prompt_pwd_color blue
set -g __prompt_git_color yellow
set -g __prompt_flag_color red
set -g __prompt_insert_color green
set -g __prompt_normal_color red

function __git_prompt_info
    set -l git_data (command git status --porcelain=2 --branch 2>/dev/null)
    or return

    set -l branch (
        string match -r '^# branch.head .*' $git_data \
        | string replace '# branch.head ' ''
    )

    if test "$branch" = "(detached)"
        set branch (
            string match -r '^# branch.oid .*' $git_data \
            | string replace '# branch.oid ' '' \
            | string sub -l 7
        )
    end

    set -l flags

    string match -qr '^# branch.ab .*?\+[1-9]' -- $git_data
    and set flags "$flags↑"

    string match -qr '^# branch.ab .*?-[1-9]' -- $git_data
    and set flags "$flags↓"

    string match -qr '^[12u?]' -- $git_data
    and set flags "$flags*"

    printf "%s\t%s" "$branch" "$flags"
end

function fish_prompt
    if contains -- --final-rendering $argv
        printf "> "
        return
    end

    set_color $__prompt_user_color
    printf "%s@%s" $USER (prompt_hostname)

    set_color $__prompt_sep_color
    printf " | "

    set_color $__prompt_pwd_color
    printf "%s" (prompt_pwd)

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

    set_color normal
    printf "\n"

    if test "$fish_bind_mode" = insert
        set_color $__prompt_insert_color
        printf "> "
    else
        set_color $__prompt_normal_color
        printf "< "
    end

    set_color normal
end

