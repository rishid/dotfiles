function _ssh-keygen
  ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519 -C "$USER@$HOSTNAME"
end
