# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is **claude-code-sync**, a tool for synchronizing Claude Code conversations across multiple machines using git with optional encryption.

Claude Code stores conversations locally in `~/.claude/`, which means:
- Conversations are machine-locked by default
- No built-in sync between computers
- Loss of conversations if machine fails
- Cannot share conversations with team members

This tool solves these problems by providing git-based sync with encryption support.

## Project Architecture

### Core Components

**Configuration System** (`lib-claude-sync.sh`)
- Two-layer configuration: env vars > local config
- Defaults hardcoded in `load_config()`, overridable via `.claude-sync-config.local`
- Validates required settings before operations
- `show_version()` function reads from VERSION file

**Sync Scripts**
- `claude-sync-init` - Clones conversations repo from remote, handles encryption unlock
- `claude-sync-push` - Merges local conversations to git remote
- `claude-sync-pull` - Pulls and merges remote conversations locally
- `claude-sync-status` - Shows configuration and sync state

**Backup System**
- `claude-backup` - Creates timestamped tar.gz backups
- `claude-restore` - Restores from backup with safety measures
- `claude-backup-list` - Lists available backups
- Auto-cleanup based on retention policy

**Security/Encryption**
- `claude-enable-encryption` - Sets up git-crypt for transparent encryption
- `claude-restore-encryption-key` - Helps restore keys from KeePass/password manager
- Base64 key export for easy storage

**Configuration**
- `claude-config` - Interactive wizard for first-time setup
- `.claude-sync-config.local` - Machine-specific settings (gitignored)
- `.claude-sync-config.example` - Template with full documentation

**Release Management**
- `claude-release` - Bumps version (patch/minor/major), updates VERSION and CHANGELOG.md
- `VERSION` - Single source of truth for version number

### Data Flow

```
~/.claude/                    conversations/              Git Remote
├── projects/                ├── projects/                (GitHub/Bitbucket)
├── file-history/    <--->   ├── file-history/    <--->   (encrypted)
├── todos/                   ├── todos/
└── history.jsonl            └── history.jsonl
```

**Sync Strategy:**
1. `claude-sync-init` clones from remote (or initializes fresh if empty)
2. `claude-sync-push` pulls latest first, then uses `rsync --update` to merge (newer files win, never delete)
3. All machines accumulate conversations from all other machines
4. Git commits track which machine contributed which conversations

### Design Decisions

**Why rsync --update?**
- Preserves newer files based on mtime
- Never deletes conversations from other machines
- Simple merge strategy that works across machines

**Why git-crypt?**
- Transparent encryption (files encrypted on remote, decrypted locally)
- No workflow changes after initial setup
- Standard tool, widely trusted

**Why local backups?**
- Safety net before first sync attempt
- Quick rollback if sync goes wrong
- Not synced to remote (local only)
- Configurable retention policy

**Why two-layer config?**
- Environment variables for temporary testing/overrides
- Local config for machine-specific settings (gitignored)
- Defaults in `lib-claude-sync.sh` ensure scripts work out of the box

## Development Guidelines

### Adding New Commands

When adding new commands:
1. Source `lib-claude-sync.sh` for configuration
2. Add `--version` flag handling using `show_version "$SCRIPT_DIR" "command-name"`
3. Save/restore `ORIGINAL_DIR` (return user to starting directory)
4. Use `$CLAUDE_DATA_DIR` not hardcoded `~/.claude`
5. Make executable with `chmod +x`
6. Update README.md Commands Reference section

### Configuration Variables

Always use these variables from config:
- `$CLAUDE_DATA_DIR` - Claude's data directory
- `$CLAUDE_SYNC_REMOTE` - Git remote URL
- `$CLAUDE_SYNC_BRANCH` - Git branch
- `$CLAUDE_SYNC_ENCRYPTION` - Encryption enabled?
- `$CLAUDE_BACKUP_RETENTION_DAYS` - Backup retention
- `$CLAUDE_SYNC_VERBOSE` - Verbose output

### Adding a New Configuration Option

1. Add default to `load_config()` in `lib-claude-sync.sh`
2. Add to `.claude-sync-config.example` with documentation
3. Update `show_config()` to display it
4. Update `claude-config` wizard if user-facing
5. Document in CONFIGURATION.md and README.md

### Error Handling

- Use `set -e` for automatic error handling
- Validate config with `validate_config` before operations
- Return to original directory on all exit paths

### Testing

Test on multiple machines:
- Fresh install (no ~/.claude exists)
- Existing conversations (merge scenario)
- After encryption enabled
- With non-standard CLAUDE_DATA_DIR

### Debugging

```bash
# See what config is active
claude-sync-status

# Test with verbose output
CLAUDE_SYNC_VERBOSE="true" claude-sync-push

# Check config loading
bash -x ./claude-sync-push 2>&1 | grep -A5 "load_config"
```

## Project Standards

### File Naming
- Scripts: `claude-*` (no extension, executable)
- Configs: `.claude-sync-config*`
- Docs: `*.md` (uppercase for top-level docs)
- Library: `lib-claude-sync.sh`

### Git Commit Style

For sync commits (automated):
```
Sync conversations - YYYY-MM-DD HH:MM:SS - hostname
```

For development commits, use conventional commits:
```
feat: add retention policy for backups
fix: correct tar exclusion for custom data dir
docs: update configuration examples
```

### Releasing New Versions

```bash
./claude-release patch  # or minor, major
# Edit CHANGELOG.md with release notes
git push origin master --tags
```

See CONTRIBUTING.md for full release process.
