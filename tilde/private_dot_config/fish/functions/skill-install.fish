function skill-install -d "Install a skill and track with chezmoi"
    if not command -q npx
        echo "✗ npx not found — install Node.js first"
        return 1
    end

    if test (count $argv) -eq 0
        echo "Usage: skill-install <source>"
        echo "Example: skill-install anthropics/skills@frontend-design"
        return 1
    end

    npx skills add --copy $argv
    if test $status -ne 0
        echo "✗ npx skills add failed"
        return 1
    end

    _skill-dotfiles-sync "feat(skill): add $argv"
    echo "✓ Skill installed and committed to dotfiles"
end
