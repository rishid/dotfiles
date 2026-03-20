function dotup -d "Update system: dotfiles, mise tools, and self"
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

    echo "" && echo "── mise upgrade (tools) ──"
    if not mise upgrade
        echo "⚠ mise upgrade failed"
        set errors (math $errors + 1)
    end

    echo "" && echo "── mise prune (cleanup old versions) ──"
    if not mise prune --yes
        echo "⚠ mise prune failed"
        set errors (math $errors + 1)
    end

    # if functions --query fisher
    #     echo "" && echo "── fisher update (fish plugins) ──"
    #     if not fisher update
    #         echo "⚠ fisher update failed"
    #         set errors (math $errors + 1)
    #     end
    # end

    echo ""
    if test $errors -eq 0
        echo "✓ System up to date"
    else
        echo "⚠ Done with $errors error(s)"
        return 1
    end
end
