function _ssh-keygen
  if not test -f ~/.ssh/id_ed25519
    ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519 -C "$USER@$HOST $(date -u '+%FT%TZ')"
  else
    echo "Key file ~/.ssh/id_ed25519 already exists."
  end
end
