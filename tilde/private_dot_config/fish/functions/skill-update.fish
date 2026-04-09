function skill-update -d "Update a skill and sync to dotfiles"
    npx skills update $argv
    if test $status -ne 0
        echo "✗ npx skills update failed"
        return 1
    end

    set -l commit_msg
    if test (count $argv) -eq 0; or contains -- --all $argv
        set commit_msg "chore(skill): update all skills"
    else
        set commit_msg "chore(skill): update $argv"
    end

    _skill-dotfiles-sync $commit_msg
    echo "✓ Skill updated and committed to dotfiles"
end
