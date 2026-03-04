function dotup -d "Update system: dotfiles, mise tools, and self"
    set -g _dotup_step 0
    set -l errors 0

    # 1. Chezmoi: pull latest dotfiles and apply
    set _dotup_step (math $_dotup_step + 1)
    echo "" && echo "── [$_dotup_step] chezmoi update (dotfiles) ──"
    if not chezmoi update
        echo "⚠ chezmoi update failed"
        set errors (math $errors + 1)
    end

    # 2. mise: update the mise binary itself
    set _dotup_step (math $_dotup_step + 1)
    echo "" && echo "── [$_dotup_step] mise self-update ──"
    if not mise self-update --yes
        echo "⚠ mise self-update failed"
        set errors (math $errors + 1)
    end

    # 3. mise: upgrade tools to latest within version constraints
    set _dotup_step (math $_dotup_step + 1)
    echo "" && echo "── [$_dotup_step] mise upgrade (tools) ──"
    if not mise upgrade
        echo "⚠ mise upgrade failed"
        set errors (math $errors + 1)
    end

    # 4. mise: prune old/unused tool versions
    set _dotup_step (math $_dotup_step + 1)
    echo "" && echo "── [$_dotup_step] mise prune (cleanup old versions) ──"
    if not mise prune --yes
        echo "⚠ mise prune failed"
        set errors (math $errors + 1)
    end

    # 5. fisher: update fish plugins
    if functions --query fisher
        set _dotup_step (math $_dotup_step + 1)
        echo "" && echo "── [$_dotup_step] fisher update (fish plugins) ──"
        if not fisher update
            echo "⚠ fisher update failed"
            set errors (math $errors + 1)
        end
    end

    set -e _dotup_step
    echo ""
    if test $errors -eq 0
        echo "✓ System up to date"
    else
        echo "⚠ Done with $errors error(s)"
        return 1
    end
end
