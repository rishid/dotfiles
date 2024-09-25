function shellcheck -d "Runs shellcheck through the system or docker depending on how it is available"
    if command -q shellcheck
        command shellcheck $argv
    # else if test -x $BIN_FOLDER/shellcheck
    #    $BIN_FOLDER/shellcheck $argv
    else if command -q docker
        docker run \
            --rm \
            -v \
            --tty \
            --volume="$PWD:/mnt" \
            docker.io/koalaman/shellcheck:latest \
            $argv
    else
        print_error "shellcheck could not be found."
        return 1
    end
end
