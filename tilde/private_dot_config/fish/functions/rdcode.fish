# Copyright 2022 Mitchell Kember. Subject to the MIT License.
# https://raw.githubusercontent.com/mk12/fish-vscode/main/functions/code.fish

function rdcode --description "Open in VS Code"
    switch (uname -s)
        case Darwin
            if test (count $argv) = 0 || string match -q -- "-*" $argv
                command code $argv
                return
            end
            for file in $arg
                test -e $file || touch $file
            end
            # This is faster and avoids a Dock animation:
            # https://github.com/microsoft/vscode/issues/60579
            open -b com.microsoft.VSCode $argv
        case Linux
            # if test ! -d ~/.vscode-server -o -n "$VSCODE_IPC_HOOK_CLI"
            if is_vscode
                # Use the regular code command if it doesn't look there is any
                # VS Code server running, *or* if it looks like we're in the VS
                # Code integrated terminal (which handles `code` specially).
                command code $argv
            else
                for s in ~/.vscode-server/bin/*
                    if pgrep -f $s &> /dev/null # && test -f $d/vscode-remote-lock.$USER.(basename $d)
                        set bins $bins $s
                    end
                end
                if test (count $bins) = 0
                    echo "Error: no VS Code remote server found" >&2
                    return
                end
                if test (count $bins) -gt 1
                    echo "Error: more than one VS Code remote server found" >&2
                    return
                end
                set code "$bins/bin/remote-cli/code"
                if not command -qv socat
                    echo "Error: please install socat" >&2
                    return
                end
                # Iterate through sockets from newest to oldest and test if valid
                for f in (command ls -t /run/user/(id -u)/vscode-ipc-*.sock)
                    if socat -u OPEN:/dev/null UNIX-CONNECT:$f &> /dev/null
                        set socks $socks $f
                    else
                        rm $f
                    end
                end
                if test (count $socks) = 0
                    echo "Error: no VS Code remote server socket found" >&2
                    return
                end
                if test (count $socks) -gt 1
                    echo "Warning: more than one VS Code remote server socket found" >&2
                end
                VSCODE_IPC_HOOK_CLI=$socks[1] $code $argv
            end
        case '*'
            command code $argv
    end
end
