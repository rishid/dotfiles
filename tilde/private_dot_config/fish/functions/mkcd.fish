function mkcd -d "Create a directory and cd into it"
  mkdir $argv[1] -p
  if test -d "$argv[1]"
    cd $argv[1]
  end
end
