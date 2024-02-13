function pull-all -d "Recursively pull git repos"
  for i in (find . -type d -name ".git")
    pushd (dirname "$i")
    git pull --rebase
    popd
  end
end
