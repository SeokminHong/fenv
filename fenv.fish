function init
    cat init.fish
end

function version
    echo "0.1.0"
end

switch $argv[1]
    case 'init'
        init
    case 'version'
        version
    case '*'
        echo "Unknown command: '$argv[1]'"
        exit 1
end
