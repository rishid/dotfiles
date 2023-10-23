function last_download
    set last_file (ls ~/Downloads -tr | tail -n 1)
    cp -v ~/Downloads/$last_file .
end
