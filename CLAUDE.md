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
- Three-layer configuration: env vars > local config > shared config
- Validates required settings before operations
- Provides helpful error messages

**Sync Scripts**
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
- `.claude-sync-config` - Shared defaults (committed)
- `.claude-sync-config.local` - Machine-specific (gitignored)
- `.claude-sync-config.example` - Template with full documentation

### Data Flow

```
~/.claude/                    conversations/              Git Remote
├── projects/                ├── projects/                (GitHub/Bitbucket)
├── file-history/    <--->   ├── file-history/    <--->   (encrypted)
├── todos/                   ├── todos/
└── history.jsonl            └── history.jsonl
```

**Sync Strategy:**
1. `claude-sync-push` pulls latest from remote first (avoid conflicts)
2. Uses `rsync --update` to merge (newer files win, never delete)
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
- Better than manual GPG encryption

**Why local backups?**
- Safety net before first sync attempt
- Quick rollback if sync goes wrong
- Not synced to remote (local only)
- Configurable retention policy

**Why three-layer config?**
- Environment variables for temporary testing/overrides
- Local config for machine-specific settings (gitignored)
- Shared config for team/project defaults (version controlled)
- Standard Unix pattern, familiar to users

## Development Guidelines

### Adding New Features

When adding new commands:
1. Source `lib-claude-sync.sh` for configuration
2. Save/restore `ORIGINAL_DIR` (return user to starting directory)
3. Use `$CLAUDE_DATA_DIR` not hardcoded `~/.claude`
4. Add to README.md and update CLAUDE.md
5. Make executable with `chmod +x`

### Configuration Variables

Always use these variables from config:
- `$CLAUDE_DATA_DIR` - Claude's data directory
- `$CLAUDE_SYNC_REMOTE` - Git remote URL
- `$CLAUDE_SYNC_BRANCH` - Git branch
- `$CLAUDE_SYNC_ENCRYPTION` - Encryption enabled?
- `$CLAUDE_BACKUP_RETENTION_DAYS` - Backup retention
- `$CLAUDE_SYNC_VERBOSE` - Verbose output

### Error Handling

- Use `set -e` for automatic error handling
- Validate config with `validate_config` before operations
- Provide helpful error messages with next steps
- Return to original directory on all exit paths

### Testing

Test on multiple machines:
- Fresh install (no ~/.claude exists)
- Existing conversations (merge scenario)
- After encryption enabled
- With non-standard CLAUDE_DATA_DIR

## Common Development Tasks

### Adding a New Configuration Option

1. Add to `.claude-sync-config.example` with documentation
2. Add to `.claude-sync-config` with default value
3. Update `load_config()` in `lib-claude-sync.sh`
4. Update `show_config()` to display it
5. Update `claude-config` wizard if user-facing
6. Document in CONFIGURATION.md

### Debugging Configuration Issues

```bash
# See what config is active
claude-sync-status

# Test with verbose output
CLAUDE_SYNC_VERBOSE="true" claude-sync-push

# Check config loading
bash -x ./claude-sync-push 2>&1 | grep -A5 "load_config"
```

### Supporting New Git Providers

The tool is provider-agnostic. It works with:
- GitHub
- Bitbucket
- GitLab
- Gitea
- Any git remote

No code changes needed - users just set `CLAUDE_SYNC_REMOTE`.

## Project Standards

### File Naming
- Scripts: `claude-*` (no extension, executable)
- Configs: `.claude-sync-config*`
- Docs: `*.md` (uppercase for top-level docs)
- Library: `lib-claude-sync.sh`

### Documentation
- README.md - User-facing quick start and usage
- CLAUDE.md - This file, for development context
- SECURITY.md - Security analysis and encryption guide
- CONFIGURATION.md - Detailed configuration reference

### Git Commit Style

Follow existing pattern:
```
Sync conversations - YYYY-MM-DD HH:MM:SS - hostname
```

For development commits, use conventional commits:
```
feat: add retention policy for backups
fix: correct tar exclusion for custom data dir
docs: update configuration examples
```

## Future Enhancements (Ideas)

- Web UI for browsing synced conversations
- Selective sync (choose which projects to sync)
- Conflict resolution UI for same conversation modified on multiple machines
- Export conversations to markdown/PDF
- Search across all synced conversations
- Support for Windows (PowerShell version)
- Homebrew formula for macOS
- Pre-commit hooks for validation
- CI/CD for testing across different environments

## Support and Contributions

When reviewing PRs:
- Ensure scripts return to original directory
- Check that configuration system is used properly
- Verify error messages are helpful
- Test on fresh install
- Update relevant documentation

For issues:
- Ask for `claude-sync-status` output
- Ask for OS/shell version
- Check for configuration issues first
- Look for permission problems with ~/.claude
