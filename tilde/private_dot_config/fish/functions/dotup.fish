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

    # fisher plugins are managed by chezmoi's onchange script (run_onchange_after_install-fisher.sh.tmpl)
    # which re-runs automatically when fish_plugins changes — no need to call fisher update here.

    echo ""
    if test $errors -eq 0
        echo "✓ System up to date"
    else
        echo "⚠ Done with $errors error(s)"
        return 1
    end
end
