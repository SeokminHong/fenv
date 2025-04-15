function __fenv_load
    set -gx my_var_test "Hello from test/.envrc.fish"
end

function __fenv_unload
    set -e my_var_test
end
