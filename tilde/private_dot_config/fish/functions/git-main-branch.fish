function git-main-branch -d "Print the main branch name (master or main)"
	if git show-ref --verify --quiet refs/heads/master
    echo "master"
  else if git show-ref --verify --quiet refs/heads/main
    echo "main"
  end
end
