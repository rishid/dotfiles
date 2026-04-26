function mkmine -d "Recursively chown a directory to the current user"
    set targets $argv
    if test (count $targets) -eq 0
        set targets (pwd)
    end

    set failed 0
    for target in $targets
        if not test -d $target
            echo "Directory '$target' does not exist." >&2
            set failed 1
            continue
        end
        if sudo chown -R $USER:$USER $target
            echo "Ownership of '$target' changed to $USER:$USER."
        else
            echo "Failed to change ownership of '$target'." >&2
            set failed 1
        end
    end
    return $failed
end
