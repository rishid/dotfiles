if status is-login
    and status is-interactive
    and command --query keychain

    set --local options --eval --quiet --ignore-missing --noask --quick
    # https://wiki.archlinux.org/title/XDG_Base_Directory#Partial
    set --append options --absolute --dir "$XDG_RUNTIME_DIR"/keychain

    # To add a key, set -Ua SSH_KEYS_TO_AUTOLOAD keypath
    # To list keys, set -S SSH_KEYS_TO_AUTOLOAD
    # To remove a key, set -U --erase SSH_KEYS_TO_AUTOLOAD[index_of_key]
    keychain $options $SSH_KEYS_TO_AUTOLOAD | source
end
