# Search .envrc.fish files in the current directory and its parents
function __fenv_search
    set -l dir (pwd)
    while test -d $dir
        # If test is root, break
        if test "$dir" = /
            break
        end
        if test -f "$dir/.envrc.fish"
            set -fp envs "$dir/.envrc.fish"
        end
        set dir (dirname $dir)
    end
    return $envs
end

