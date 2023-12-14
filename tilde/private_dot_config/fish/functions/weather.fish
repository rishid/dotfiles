function weather --description "Shows weather"
    set city Hopkinton,MA
    if test (count $argv) -eq 1
        set city $argv[1]
    end
    curl -4 http://wttr.in/$city
end
