#!/usr/bin/env fish

# __fenv_search 함수: 현재 디렉토리부터 상위 디렉토리까지의 .envrc.fish 파일들을 찾음
function __fenv_search --description 'Search .envrc.fish files from current directory up to root'
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
    echo $envs
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
    set hash (sha256sum "$file" | awk '{print $1}')
    echo $hash
end

# __fenv_cache_metadata 함수: .envrc.fish 경로와 해시 정보를 캐시 파일에 저장
function __fenv_cache_metadata --description 'Cache .envrc.fish file path to hash metadata'
    # 부모 쉘의 PID를 사용하여 캐시 파일 이름 지정 ($fish_pid는 fish에서 현재 프로세스 ID)
    set -l ppid (ps -o ppid= -p $fish_pid)
    set -l cache_file /tmp/fenv.$ppid.cache

    # 기존 캐시 파일 삭제(있다면)
    if test -f $cache_file
        rm $cache_file
    end

    # __fenv_search로 수집한 .envrc.fish 파일들에 대해 해시값 계산 후 캐시에 기록
    for env_file in (string split ' ' (__fenv_search))
        set -l hash_value (__fenv_hash_file "$env_file")
        if test $status -eq 0
            # 각 줄에 "파일경로 해시값" 형태로 기록
            echo "$env_file $hash_value" >>$cache_file
        end
    end
    echo "Cache updated in $cache_file"
end

__fenv_cache_metadata
