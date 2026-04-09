# Set up Homebrew environment on macOS
# Ensures brew-installed tools are in PATH for all fish sessions
if test (uname) = "Darwin"
    if test -x /opt/homebrew/bin/brew
        # Apple Silicon
        eval (/opt/homebrew/bin/brew shellenv)
    else if test -x /usr/local/bin/brew
        # Intel
        eval (/usr/local/bin/brew shellenv)
    end
end
