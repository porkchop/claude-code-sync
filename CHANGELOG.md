# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-02

### Added
- Initial public release
- Multi-machine conversation sync via git
- Optional transparent encryption with git-crypt
- Backup and restore system with auto-cleanup
- Three-layer configuration system (env vars > local config > shared config)
- Separate initialization workflow (`claude-sync-init`)
- Encryption lock detection and validation
- Project migration utility (`claude-migrate-project`)
- Comprehensive documentation for Linux, macOS, and Windows WSL
- Platform-specific git-crypt installation instructions
- Detailed troubleshooting guide
- Support for GitHub, Bitbucket, GitLab, and any git provider

### Commands
- `claude-sync-init` - Initialize/clone conversations repository
- `claude-sync-push` - Sync local conversations to remote
- `claude-sync-pull` - Pull remote conversations to local
- `claude-sync-status` - Show configuration and sync status
- `claude-backup` - Create timestamped backup
- `claude-backup-list` - List available backups
- `claude-restore` - Restore from backup
- `claude-config` - Interactive configuration wizard
- `claude-enable-encryption` - Enable git-crypt encryption
- `claude-restore-encryption-key` - Restore encryption key
- `claude-migrate-project` - Migrate project conversation paths

### Configuration
- `CLAUDE_SYNC_REMOTE` - Git remote URL
- `CLAUDE_SYNC_BRANCH` - Git branch (default: main)
- `CLAUDE_SYNC_ENCRYPTION` - Enable encryption (default: false)
- `CLAUDE_BACKUP_RETENTION_DAYS` - Backup retention (default: 30)
- `CLAUDE_DATA_DIR` - Claude data directory (default: ~/.claude)
- `CLAUDE_SYNC_VERBOSE` - Verbose output (default: false)
- `CLAUDE_SYNC_COMMIT_MSG` - Commit message template

### Security
- Private repository recommendation
- Optional git-crypt encryption
- Encryption key storage in password managers
- Automatic exclusion of credentials files

[1.0.0]: https://github.com/porkchop/claude-code-sync/releases/tag/v1.0.0
