# =============================================================================
# Smart Move
# =============================================================================
#
# Automatically uses `git mv` for tracked files moved inside the same Git
# repository. Falls back to normal `mv` for outside moves or non-Git files.

function mv --wraps mv --description "Tweaked mv to automatically use git mv when appropriate"
    # Only handle: mv source destination
    if test (count $argv) -ne 2
        command mv -v $argv
        return
    end

    # Check if inside a Git repository.
    set -l git_root (git rev-parse --show-toplevel 2>/dev/null)

    if test $status -ne 0
        command mv -v $argv
        return
    end

    # Check if source is tracked.
    git ls-files --error-unmatch -- $argv[1] >/dev/null 2>&1
    if test $status -ne 0
        command mv -v $argv
        return
    end

    # Convert destination to an absolute path.
    set -l destination (realpath $argv[2] 2>/dev/null)

    # Destination does not exist yet, so resolve its parent directory.
    if test $status -ne 0
        set destination (realpath (dirname $argv[2]))
    end

    # Use git mv only when destination stays inside the repository.
    if string match -q "$git_root*" "$destination"
        git mv -v $argv
    else
        command mv -v $argv
    end
end

