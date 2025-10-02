# SSH Agent Setup with systemd

This setup replaces the keychain approach with a modern systemd user service for managing SSH agent.

## Initial Setup

1. **Enable and start the ssh-agent service:**
   ```bash
   systemctl --user enable ssh-agent.service
   systemctl --user start ssh-agent.service
   ```

2. **Verify the service is running:**
   ```bash
   systemctl --user status ssh-agent.service
   ```

3. **Reload your fish shell or source the new configuration:**
   ```bash
   exec fish
   # or
   source ~/.config/fish/conf.d/ssh-agent.fish
   ```

## Adding SSH Keys

### Method 1: Interactive (Recommended)
```bash
ssh-key-add ~/.ssh/id_rsa
ssh-key-add ~/.ssh/github_akamai
```

### Method 2: Manual Configuration
Create or edit `~/.ssh/autoload` with one key path per line:
```
# SSH Keys to auto-load
~/.ssh/id_ed25519
~/.ssh/id_rsa
~/.ssh/github_akamai
~/.ssh/work_key
```

Lines starting with `#` are ignored (comments), so you can temporarily disable keys:
```
# ~/.ssh/old_key    # temporarily disabled
~/.ssh/current_key
```

## Management Commands

- `ssh-key-add <path>` - Add a key to the agent and optionally to auto-load
- `ssh-key-list` - Show loaded keys and all auto-load configurations
- `ssh-agent-status` - Check service status and loaded keys
- `ssh-add -l` - List currently loaded keys
- `systemctl --user restart ssh-agent.service` - Restart the service

## Key Features

1. **Persistent across sessions:** The systemd service runs independently of shell sessions
2. **Works with remote SSH:** The SSH_AUTH_SOCK is properly set in the systemd environment
3. **Single source of truth:** Only `~/.ssh/autoload` controls which keys are loaded
4. **Reliable:** systemd manages the service lifecycle with automatic restart on failure
5. **Simple and explicit:** No magic auto-discovery, you control exactly which keys are loaded

## Troubleshooting

### If SSH agent is not working:
```bash
# Check service status
systemctl --user status ssh-agent.service

# Check environment
echo $SSH_AUTH_SOCK
systemctl --user show-environment | grep SSH_AUTH_SOCK

# Restart everything
systemctl --user restart ssh-agent.service
exec fish
```

### For VS Code Remote SSH issues:
The systemd approach should resolve most remote SSH issues, but if you're still getting passphrase prompts:

1. **Run the debug script:**
   ```bash
   ssh-agent-debug
   ```

2. **Check SSH config has agent forwarding:**
   ```bash
   # Your ~/.ssh/config should have:
   Host *
       ForwardAgent yes
       AddKeysToAgent yes
   ```

3. **Test SSH connection manually:**
   ```bash
   ssh -T git@github.com  # Should not ask for passphrase
   ```

4. **VS Code specific fixes:**
   - Restart VS Code completely (not just reload window)
   - In VS Code settings, ensure "Remote.SSH: Use Local Server" is enabled
   - Try connecting to remote host via terminal first, then VS Code

5. **If still failing, check:**
   - SSH_AUTH_SOCK is available in non-interactive shells: `ssh remotehost 'echo $SSH_AUTH_SOCK'`
   - Keys are loaded: `ssh remotehost 'ssh-add -l'`

### Common Issues:
- **"Agent admitted failure to sign"**: Key not loaded or wrong key permissions
- **"Could not open a connection to your authentication agent"**: SSH_AUTH_SOCK not set
- **VS Code asks for passphrase despite working terminal**: SSH agent not forwarded properly

## Migration from keychain

1. Remove any keychain package if no longer needed: `sudo apt remove keychain` (or equivalent)
2. The systemd service will automatically start on login and persist across sessions
3. Use `ssh-key-add` to add your existing keys to the new system, or place them in `~/.ssh/autoload`
