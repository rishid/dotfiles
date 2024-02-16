function ce
	set SEARCH_RESULT (chezmoi managed --exclude=externals --include=files | fzf)
	if test $status -eq 0
		chezmoi edit --watch --apply $HOME/$SEARCH_RESULT
	end
end
