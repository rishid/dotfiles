function _ssh-keygen -d "Generate an ed25519 SSH key if none exists"
  if not test -f ~/.ssh/id_ed25519
    ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519 -C "$(whoami)@$(uname -n) $(date -u '+%FT%TZ')"
  else
    echo "Key file ~/.ssh/id_ed25519 already exists."
  end
end
