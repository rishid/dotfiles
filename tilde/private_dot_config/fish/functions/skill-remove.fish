function skill-remove -d "Remove a skill and update dotfiles"
    if test (count $argv) -eq 0
        echo "Usage: skill-remove <skill-name>"
        return 1
    end

    npx skills remove $argv
    if test $status -ne 0
        echo "✗ npx skills remove failed"
        return 1
    end

    _skill-dotfiles-sync "chore(skill): remove $argv"
    echo "✓ Skill removed and committed to dotfiles"
end
