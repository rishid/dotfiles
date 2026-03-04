function dotup -d "Update system: dotfiles, mise tools, and self"
    set -l step 0
    set -l errors 0

    function _dotup_step
        set step (math $step + 1)
        echo ""
        echo "── [$step] $argv ──"
    end

    # 1. Chezmoi: pull latest dotfiles and apply
    _dotup_step "chezmoi update (dotfiles)"
    if not chezmoi update
        echo "⚠ chezmoi update failed"
        set errors (math $errors + 1)
    end

    # 2. mise: update the mise binary itself
    _dotup_step "mise self-update"
    if not mise self-update --yes
        echo "⚠ mise self-update failed"
        set errors (math $errors + 1)
    end

    # 3. mise: upgrade tools to latest within version constraints
    _dotup_step "mise upgrade (tools)"
    if not mise upgrade
        echo "⚠ mise upgrade failed"
        set errors (math $errors + 1)
    end

    # 4. mise: prune old/unused tool versions
    _dotup_step "mise prune (cleanup old versions)"
    if not mise prune --yes
        echo "⚠ mise prune failed"
        set errors (math $errors + 1)
    end

    # 5. fisher: update fish plugins
    if functions --query fisher
        _dotup_step "fisher update (fish plugins)"
        if not fisher update
            echo "⚠ fisher update failed"
            set errors (math $errors + 1)
        end
    end

    echo ""
    if test $errors -eq 0
        echo "✓ System up to date"
    else
        echo "⚠ Done with $errors error(s)"
        return 1
    end
end
