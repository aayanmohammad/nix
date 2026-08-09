set -g fish_greeting

set -gx EDITOR (command -v nvim)
set -gx VISUAL $EDITOR

set -gx PATH ~/.nix-profile/bin $PATH

if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end

