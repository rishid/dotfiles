function _ssh-keygen
  set name $argv[1]
  mkdir -p "$HOME/.ssh/$name"
  ssh-keygen -t ed25519 -f "$HOME/.ssh/$name/id_ed25519"
end
