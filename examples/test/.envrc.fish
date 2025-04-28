function fenv_load
    set -gx my_var_test "Hello from test/.envrc.fish"
end

function fenv_unload
    set -e my_var_test
end
