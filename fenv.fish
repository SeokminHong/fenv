#!/usr/bin/env fish

function __fenv_load -S --on-event fish_prompt
    set -l envs
    # 현재 디렉토리부터 상위 디렉토리까지의 .envrc.fish 파일들을 찾음
    set -l dir (pwd)
    while test -d $dir
        # If test is root, break
        if test "$dir" = /
            break
        end
        if test -f "$dir/.envrc.fish"
            set -p envs "$dir/.envrc.fish"
        end
        set dir (dirname $dir)
    end

    set -l cache_dir /tmp/fenv.cache

    # 캐시 디렉토리 생성
    mkdir -p $cache_dir
    # 캐시 디렉토리의 권한을 700으로 설정
    chmod 700 $cache_dir

    # New stack
    set -f new_envs
    for env_file in $envs
        set -l env_file_hash (__fenv_hash_file $env_file)
        set -fa new_envs (string join '///' $env_file_hash $env_file)
    end

    set base_index 0
    # Found common envs
    for old_env in $fenv_stack
        set -l old_env_value (string split '///' $old_env)
        set -l old_env_hash $old_env_value[1]
        set -l old_env_file $old_env_value[2]

        set -l found 0
        for new_env in $new_envs
            set -l new_env_value (string split '///' $new_env)
            set -l new_env_hash $new_env_value[1]
            set -l new_env_file $new_env_value[2]

            if test "$old_env_hash" = "$new_env_hash"
                and test "$old_env_file" = "$new_env_file"
                set found 1
                break
            end
        end
        if test $found -eq 0
            break
        else
            set base_index (math $base_index + 1)
        end
    end

    for old_env in $fenv_stack[-1..(math $base_index + 1)]
        set -l old_env_value (string split '///' $old_env)
        set -l old_env_hash $old_env_value[1]
        set -l old_env_file $old_env_value[2]
        echo "fenv: Unloading $old_env_file"
        if test -f "$cache_dir/$old_env_hash"
            # Unload old env
            # source "$cache_dir/$old_env_hash"
            # if functions -q __fenv_unload
            #     __fenv_unload
            #     functions -e __fenv_unload
            # end
        end
    end

    for new_env in $new_envs[(math $base_index + 1)..-1]
        set -l new_env_value (string split '///' $new_env)
        set -l new_env_hash $new_env_value[1]
        set -l new_env_file $new_env_value[2]

        # Load new env
        echo "fenv: Loading $new_env_file"
        cp $new_env_file "$cache_dir/$new_env_hash"
        # source "$cache_dir/$new_env_hash"
        # if functions -q __fenv_load
        #     __fenv_load
        #     functions -e __fenv_load
        # end
    end

    set -gx fenv_stack $new_envs
end

# __fenv_hash_file 함수: 주어진 파일에 대해 sha256 해시 값을 계산함
function __fenv_hash_file --description 'Compute sha256 hash of a given file'
    if test (count $argv) -eq 0
        return 1
    end

    set file $argv[1]
    if not test -f $file
        return 1
    end

    # sha256sum 결과의 첫번째 필드를 추출
    set hash (sha256sum "$file" | string split ' ')[1]
    echo $hash
end
