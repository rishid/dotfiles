function mkmine
    if test -z $argv
        set target_dir (pwd)
    else
        set target_dir $argv[1]
    end

    if test -d $target_dir
        chown -R $USER:$USER $target_dir
        echo "Ownership of '$target_dir' changed to $USER:$USER."
    else
        echo "Directory '$target_dir' does not exist."
    end
end
