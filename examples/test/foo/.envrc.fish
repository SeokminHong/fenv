function fenv_load
    complete -c myprog -l output -a '(myprog list-outputs)'
    echo 'A completion for myprog is registered. Try `myprog -o<tab>`'
end

function fenv_unload
    complete -e myprog -l output
end
