#!/usr/bin/env fish

function __fenv -S
    # Local variable to hold list of discovered env files
    set -l envs

    # Start from current working directory
    set -l dir (pwd)
    while test -d $dir
        # Stop if we've reached the filesystem root
        if test "$dir" = /
            break
        end
        # If a .envrc.fish file exists in this directory, prepend it to the list
        if test -f "$dir/.envrc.fish"
            set -p envs "$dir/.envrc.fish"
        end
        # Move up one directory level
        set dir (dirname $dir)
    end

    # Directory to cache compiled env files by hash
    set -l cache_dir /tmp/fenv.cache

    # Ensure the cache directory exists and is secure
    mkdir -p $cache_dir
    chmod 700 $cache_dir

    # Build a new list (stack) of envs with their hashes
    set -l new_envs
    for env_file in $envs
        # Compute hash of the env file
        set -l env_file_hash (__fenv_hash_file $env_file)
        # Store combined record: hash///filepath
        set -a new_envs (string join '///' $env_file_hash $env_file)
    end

    # Determine how many leading entries fenv_stack and new_envs have in common
    set -l base_index 0
    for old_env in $fenv_stack
        if contains $old_env $new_envs
            set base_index (math $base_index + 1)
        else
            break
        end
    end

    # Unload any previously loaded envs that are no longer present
    for old_env in $fenv_stack[-1..(math $base_index + 1)]
        # Split record into hash and file path
        set -l old_env_value (string split '///' $old_env)
        set -l old_env_hash $old_env_value[1]
        set -l old_env_file $old_env_value[2]
        echo "fenv: Unloading $old_env_file"

        # If we have a cached copy, source it to run its unload function
        if test -f "$cache_dir/$old_env_hash"
            set -x ENVRC_PATH "$old_env_file"
            source "$cache_dir/$old_env_hash"
            # If __fenv_unload is defined by the script, call and then erase it
            if functions -q __fenv_unload
                __fenv_unload
                functions -e __fenv_unload
            end
        end
    end

    # Load any new env files that were not previously loaded
    for new_env in $new_envs[(math $base_index + 1)..-1]
        set -l new_env_value (string split '///' $new_env)
        set -l new_env_hash $new_env_value[1]
        set -l new_env_file $new_env_value[2]

        echo "fenv: Loading $new_env_file"
        # Copy the env file into cache under its hash name
        cp $new_env_file "$cache_dir/$new_env_hash"
        set -x ENVRC_PATH "$new_env_file"
        # Source the cached file so its __fenv_load can execute
        source "$cache_dir/$new_env_hash"
        # Call and then cleanup the __fenv_load function if defined
        if functions -q __fenv_load
            __fenv_load
            functions -e __fenv_load
        end
    end

    # Update the global stack variable to reflect newly loaded environment files
    set -x fenv_stack $new_envs
end

function __fenv_hash_file --description 'Compute sha256 hash of a given file'
    # If no file argument provided, return error
    if test (count $argv) -eq 0
        return 1
    end

    set file $argv[1]
    # If the file does not exist, return error
    if not test -f $file
        return 1
    end

    # Compute sha256sum and extract only the hash
    set hash (sha256sum "$file" | string split ' ')[1]
    echo $hash
end

# Hook into prompt event: run __fenv before each prompt redraw
function __fenv_prompt -S --on-event fish_prompt
    __fenv
end

# Hook into preexec event: run __fenv before each command execution
function __fenv_preexec -S --on-event fish_preexec
    __fenv
end
