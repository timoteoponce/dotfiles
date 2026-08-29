function dsh --description 'Pick a running container with fzf and open a shell in it'
    if not type -q docker
        echo "docker not found" >&2
        return 1
    end

    set -l ids (docker ps --format '{{.ID}}\t{{.Names}}\t{{.Image}}')
    if test -z "$ids"
        echo "no running containers" >&2
        return 1
    end

    set -l picked (printf '%s\n' $ids | fzf --with-nth=2.. --height=40% --reverse --header='container to shell into')
    or return 1

    set -l id (string split \t -- $picked)[1]
    docker exec -it $id sh -c 'exec bash 2>/dev/null || exec sh'
end
