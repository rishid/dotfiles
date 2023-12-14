
# note: can try to modify to open in VSCode with code -g "$file:$linenumber"
function frg --description "rg tui built with fzf and bat"
    rg --ignore-case --color=always --line-number --no-heading "$argv" |
        fzf --ansi \
            --color 'hl:-1:underline,hl+:-1:underline:reverse' \
            --delimiter ':' \
            --preview "bat --color=always {1} --theme='Solarized (light)' --highlight-line {2}" \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
            --bind "enter:become($EDITOR +{2} {1})"
end
