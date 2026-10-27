function cloc --wraps tokei --description "Count lines of code with Tokei, sorted by code lines"
    command tokei --sort code --hidden --exclude .git $argv
end
