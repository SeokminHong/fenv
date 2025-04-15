function __fenv_load
    set -gx my_var "Hello from .envrc.fish"
end

function __fenv_unload
    set -e my_var
end
