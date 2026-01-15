# /chezmoi-apply - Apply chezmoi changes with conflict resolution

This command applies all staged changes from the chezmoi source directory to your home directory with intelligent conflict handling.

## Command Behavior

When you run `/chezmoi-apply`, Claude will:

1. Show a preview of changes using `chezmoi diff --no-tty`
2. Attempt to apply changes using `chezmoi apply --no-tty`
3. If conflicts are detected:
   - Display the conflicting files and their differences
   - Present options: overwrite, skip, or quit for each conflict
   - Wait for user decision before proceeding
4. Report the final result of the operation

## Conflict Resolution Options

When conflicts occur, you'll be prompted with these options for each file:
- **overwrite**: Replace the target file with chezmoi's version
- **skip**: Keep the existing file and skip this change
- **quit**: Stop the apply process entirely

## Usage

Simply type `/chezmoi-apply` in your conversation.

## Examples

```
/chezmoi-apply
```

If conflicts occur, you'll see:
```
Conflict detected in: ~/.config/example.conf
Choose action: overwrite/skip/quit?
```

## Security

This command is safe to use as it only applies changes that are already staged in your chezmoi source directory. The conflict resolution ensures you maintain control over which changes are applied.

## Related Commands

- Use regular file editing commands to modify files in the chezmoi source directory first
- This command only applies changes; it doesn't modify source files
