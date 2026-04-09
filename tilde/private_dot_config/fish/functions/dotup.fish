function dotup -d "Update system: dotfiles, mise tools, and fish plugins"
    set -l errors 0

    echo "" && echo "── chezmoi update (dotfiles) ──"
    if not chezmoi update
        echo "⚠ chezmoi update failed"
        set errors (math $errors + 1)
    end

    echo "" && echo "── mise self-update ──"
    if not mise self-update --yes
        echo "⚠ mise self-update failed"
        set errors (math $errors + 1)
    end

    # Install any tools newly added to mise/config.toml
    echo "" && echo "── mise install (new tools) ──"
    if not mise install
        echo "⚠ mise install failed"
        set errors (math $errors + 1)
    end

    echo "" && echo "── mise upgrade (all tools to latest) ──"
    if not mise upgrade
        echo "⚠ mise upgrade failed"
        set errors (math $errors + 1)
    end

    echo "" && echo "── mise prune (cleanup old versions) ──"
    if not mise prune --yes
        echo "⚠ mise prune failed"
        set errors (math $errors + 1)
    end

    echo "" && echo "── fisher update (fish plugins) ──"
    if functions --query fisher
        if not fisher update
            echo "⚠ fisher update failed"
            set errors (math $errors + 1)
        end
    else
        echo "fisher not installed, skipping"
    end

    echo ""
    if test $errors -eq 0
        echo "✓ System up to date"
    else
        echo "⚠ Done with $errors error(s)"
        return 1
    end
end
