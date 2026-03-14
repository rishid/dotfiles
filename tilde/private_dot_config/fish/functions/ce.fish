function ce -d "Fuzzy-find and edit a chezmoi-managed file"
    set SEARCH_RESULT (chezmoi managed --exclude=externals --include=files | fzf --prompt="chezmoi> " --query=(string join " " $argv))
    test $status -eq 0 || return 0

    set target "$HOME/$SEARCH_RESULT"

    chezmoi edit $target
end
