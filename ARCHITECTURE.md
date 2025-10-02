# Dotfiles Architecture: Chezmoi + Mise

This document defines the clear boundary between chezmoi and mise responsibilities in this dotfiles setup.

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Chezmoi     │    │      Mise       │    │   System/Manual │
│   (Dotfiles)    │    │  (Dev Tools)    │    │  (Heavy Deps)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Responsibility Matrix

### ✅ Chezmoi Handles
- **Configuration files**: Shell configs, application settings, themes
- **Dotfiles management**: `.bashrc`, `.gitconfig`, `.ssh/config`, etc.
- **Basic system packages**: Only essential packages needed for dotfile functionality
- **Shell integration**: Fish, bash, zsh configurations
- **Application configs**: VS Code settings, tmux config, etc.

**Packages chezmoi should install:**
```yaml
apt:
  install:
    - git                 # Required for chezmoi
    - curl, wget          # Download utilities
    - build-essential     # Compilers (often needed)
    - openssh-server      # System SSH service
    - htop, tree, jq      # Basic system utilities
    - keychain            # SSH key management
```

### ✅ Mise Handles
- **All development tools**: CLI utilities, build tools, dev utilities
- **Programming language runtimes**: Go, Node.js, Python, Java, etc.
- **Version-managed tools**: Tools that benefit from version management
- **Project-specific tools**: Tools that vary by project/directory

**Tools mise should manage:**
```toml
[tools]
# Development & CLI tools
gh = "2.81.0"           # GitHub CLI
kubectl = "1.34.1"      # Kubernetes CLI
helm = "3.19.0"         # K8s package manager
terraform = "1.9.0"     # Infrastructure as code

# Utilities
bat = "0.25.0"          # Better cat
fzf = "0.65.2"          # Fuzzy finder
ripgrep = "14.1.1"      # Better grep
starship = "1.23.0"     # Shell prompt

# Language runtimes
go = "1.25.1"
node = "latest"
python = "3.12"
```

### ⚠️ System/Manual Handles
- **Major system dependencies**: Docker, Docker Compose
- **System services**: Database servers, web servers
- **OS-specific packages**: Distribution-specific heavy packages
- **Hardware-specific**: Drivers, system-level tools

**Examples requiring manual installation:**
- Docker Engine (too complex, system-specific)
- Database servers (PostgreSQL, MySQL)
- System services (nginx, systemd services)

## Migration Benefits

### Before (Problems):
- ❌ Duplication: Same tools in both chezmoi and mise
- ❌ Complexity: Large binary downloads in chezmoi
- ❌ Inconsistency: Different version management approaches
- ❌ Maintenance: Manual version updates in multiple places

### After (Solutions):
- ✅ **Clear boundaries**: Each tool has one home
- ✅ **Automatic updates**: Mise handles tool version management
- ✅ **Project flexibility**: Per-directory tool versions with mise
- ✅ **Faster chezmoi**: No large binary downloads
- ✅ **Better caching**: Mise handles downloads and caching

## Implementation Steps

1. **Install mise** and configure shell integration
2. **Run migration script** to clean up chezmoi binaries
3. **Update chezmoi config** with minimal package list
4. **Remove chezmoi external** tool downloads
5. **Test everything** works via mise

## Per-Directory Tool Management

With mise, you can now have project-specific tool versions:

```bash
# In a specific project directory
echo "node 18.17.0" > .tool-versions
echo "terraform 1.5.0" >> .tool-versions

# mise automatically switches versions when entering the directory
cd my-project/       # Automatically uses node 18.17.0 and terraform 1.5.0
cd ../other-project/ # Back to global versions
```

## Troubleshooting

### Missing Tools After Migration
```bash
# Check mise installation
mise doctor

# Reinstall all tools
mise install

# Check tool availability
mise which gh
```

### Shell Integration Issues
```bash
# For fish shell
echo 'mise activate fish | source' >> ~/.config/fish/config.fish

# For bash
echo 'eval "$(mise activate bash)"' >> ~/.bashrc
```

This architecture provides cleaner separation of concerns and better tool management while keeping the strengths of both chezmoi and mise.
