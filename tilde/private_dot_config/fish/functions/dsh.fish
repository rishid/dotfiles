
function dsh --description "Enter a shell in a container"
    docker exec -it $argv[1] /bin/sh
end
