function ce -d "Fuzzy-find and edit a chezmoi-managed file"
	set SEARCH_RESULT (chezmoi managed --exclude=externals --include=files | fzf)
	if test $status -eq 0
        echo "foobar"
		chezmoi edit --watch --apply $HOME/$SEARCH_RESULT
	end
end
