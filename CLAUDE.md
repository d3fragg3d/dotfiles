# Claude Code Contract

Emacs configuration dotfiles focused on Common Lisp development with SLY.

## Constraints

- Make small, incremental changes only
- Never refactor large sections unless explicitly instructed
- Preserve existing keybindings and behaviour
- Emacs must remain bootable after every change
- One logical change per commit

## Workflow

1. **Plan first**: Propose changes before implementing
2. **Branch**: Work on a feature branch, not main
3. **Summarise**: List files changed and explain why
4. **Test**: Provide commands to verify changes work

## Structure

```
emacs/.emacs.d/
├── init.el          # Entry point - loads config modules
└── config/          # One file per feature
    ├── packages.el  # Package management (use-package)
    ├── lisp.el      # SLY and Common Lisp setup
    └── ...          # Other features
```

## Testing

Verify Emacs boots without errors:
```bash
emacs --batch -l ~/.emacs.d/init.el --eval '(message "Init OK")' 2>&1
```

Interactive sanity check:
```bash
emacs -Q -l ~/.emacs.d/init.el
```

## Key Packages

- **SLY**: Common Lisp IDE
- **Vertico/Consult**: Completion
- **Projectile**: Project navigation
- **use-package**: Package declarations
