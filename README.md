# Claude Code Conversation Sync

Synchronize your Claude Code conversations across multiple computers using git, with optional encryption.

## Why?

Claude Code stores conversations locally in `~/.claude/`, which means:
- ❌ Conversations are machine-locked
- ❌ No sync between computers
- ❌ Risk of losing conversations if machine fails
- ❌ Can't easily share with team members

**This tool fixes that:**
- ✅ Sync conversations across all your machines
- ✅ Git-based version control
- ✅ Optional transparent encryption (git-crypt)
- ✅ Local backups with auto-cleanup
- ✅ Works with any git provider (GitHub, Bitbucket, GitLab, etc.)

## Quick Start

### Installation

```bash
git clone https://github.com/porkchop/claude-code-sync.git
cd claude-code-sync
chmod +x claude-*
```

Add to your PATH (add this to `~/.bashrc` or `~/.zshrc`):
```bash
export PATH="$HOME/claude-code-sync:$PATH"
```

### Initial Setup (First Machine)

1. **Create a git repository** for your conversations on GitHub/Bitbucket/GitLab (private repo recommended)

2. **Configure sync settings**:
   ```bash
   claude-config
   ```

3. **Create your first backup** (safety first!):
   ```bash
   claude-backup
   ```

4. **Initialize the repository**:
   ```bash
   claude-sync-init
   ```

5. **(Optional) Enable encryption**:
   ```bash
   claude-enable-encryption
   ```
   Save the encryption key to your password manager (KeePass, 1Password, etc.)

6. **Push your conversations**:
   ```bash
   claude-sync-push
   ```

### Setup on Additional Machines

1. **Clone this tool**:
   ```bash
   git clone https://github.com/porkchop/claude-code-sync.git
   cd claude-code-sync
   chmod +x claude-*
   ```

2. **Add to PATH** (same as above)

3. **Configure with same remote URL**:
   ```bash
   claude-config
   ```

4. **Create a backup** of this machine's existing conversations:
   ```bash
   claude-backup
   ```

5. **If using encryption**, restore your key first:
   ```bash
   claude-restore-encryption-key
   ```

6. **Initialize and clone the repository**:
   ```bash
   claude-sync-init
   ```
   This will clone from remote and unlock encryption if needed.

7. **Sync conversations to your local Claude**:
   ```bash
   claude-sync-pull
   ```

8. **Add this machine's conversations to the pool**:
   ```bash
   claude-sync-push
   ```

9. **Restart Claude Code** to see all synced conversations

## Daily Usage

### Before Starting Work
```bash
claude-sync-pull
```

### After Working / Before Switching Machines
```bash
claude-sync-push
```

### Check Status
```bash
claude-sync-status  # Shows config, sync state, conversation counts
```

### Manage Configuration
```bash
claude-config  # Edit settings interactively
```

## Features

### 🔄 Multi-Machine Sync

Conversations **accumulate** across all machines:
- **Machine A** has conversations 1, 2, 3
- **Machine B** has conversations 3, 4, 5 (conversation 3 updated more recently)
- After syncing: **Both machines have 1, 2, 3 (B's version), 4, 5**

⚠️ **Important:** Claude Code stores conversations by project path. For sync to work correctly, **your projects must be at the same absolute paths on all machines**. For example, if you work in `/home/alice/projects/myapp` on one machine, use the same path on others.

If you need to move a project, use `claude-migrate-project` to update the conversation paths (see Utilities below).

### 🔐 Optional Encryption

Enable transparent encryption with git-crypt:

```bash
# Install git-crypt
sudo apt install git-crypt  # Ubuntu/Debian
brew install git-crypt      # macOS
```

**First machine (enable encryption):**
```bash
claude-sync-init             # Initialize repo first
claude-enable-encryption     # Set up encryption, generates key
claude-sync-push             # Push encrypted conversations
```

The script will generate an encryption key and display it in base64 format.
**Save this key to your password manager immediately!**

**On other machines:**
```bash
claude-restore-encryption-key  # Restore key from password manager
claude-sync-init               # Clone and unlock repository
claude-sync-pull               # Sync conversations
```

### 💾 Backup & Restore

**Create backups:**
```bash
claude-backup  # Creates timestamped backup
```

**List backups:**
```bash
claude-backup-list
```

**Restore from backup:**
```bash
claude-restore <backup-name>
```

Backups are:
- Compressed (tar.gz)
- Timestamped with machine name
- Stored locally (not synced)
- Auto-cleaned based on retention policy (default: 30 days)

## Configuration

Configuration uses three layers (priority: highest to lowest):

1. **Environment variables** - `CLAUDE_SYNC_*`
2. **Local config** - `.claude-sync-config.local` (machine-specific, gitignored)
3. **Shared config** - `.claude-sync-config` (defaults, version controlled)

### Available Settings

- `CLAUDE_SYNC_REMOTE` - Git remote URL (required)
- `CLAUDE_SYNC_BRANCH` - Git branch (default: `main`)
- `CLAUDE_SYNC_ENCRYPTION` - Enable encryption (default: `false`)
- `CLAUDE_BACKUP_RETENTION_DAYS` - Backup retention (default: `30`)
- `CLAUDE_DATA_DIR` - Claude data directory (default: `~/.claude`)
- `CLAUDE_SYNC_VERBOSE` - Verbose output (default: `false`)

See [CONFIGURATION.md](CONFIGURATION.md) for detailed configuration guide.

## How It Works

### Sync Strategy

**Init** (`claude-sync-init`):
1. Clones conversations repository from remote (or initializes fresh if empty)
2. Detects encryption and prompts for unlock if needed
3. Prepares repository for push/pull operations

**Push** (`claude-sync-push`):
1. Pulls latest from remote (avoid conflicts)
2. Merges local conversations using `rsync --update`
3. Commits and pushes to remote

**Pull** (`claude-sync-pull`):
1. Pulls from remote
2. Merges into `~/.claude/` (preserves newer files)

**Conflict Resolution:**
- Same conversation UUID: Newer file wins (based on modification time)
- Different UUIDs: All conversations kept (merged)
- History: Deduplicated and merged

### What Gets Synced

```
~/.claude/
├── projects/        → Conversation files (.jsonl)
├── file-history/    → File edit history
├── todos/           → Todo lists
└── history.jsonl    → Command history
```

### What's Excluded

- `.credentials.json` (never synced)
- Debug files
- Local backups

## Security & Privacy

⚠️ **Important:** Conversations contain:
- Full text of all messages
- All code discussed or generated
- File paths and project structure
- System information

**Recommendations:**
- ✅ Use **private** git repository
- ✅ Enable **encryption** for sensitive work
- ✅ Store encryption key in **password manager** (KeePass, 1Password, etc.)
- ✅ Never commit real API keys or secrets in conversations

See [SECURITY.md](SECURITY.md) for full security analysis and encryption guide.

## Commands Reference

### Setup Commands
- `claude-config` - Interactive configuration wizard
- `claude-sync-init` - Initialize/clone the conversations repository

### Sync Commands
- `claude-sync-push` - Sync local → remote (pull, merge, push)
- `claude-sync-pull` - Sync remote → local
- `claude-sync-status` - Show status and configuration

### Backup Commands
- `claude-backup` - Create timestamped backup
- `claude-backup-list` - List available backups
- `claude-restore <name>` - Restore from backup

### Encryption Commands
- `claude-enable-encryption` - Enable git-crypt encryption
- `claude-restore-encryption-key` - Restore encryption key from password manager

### Utility Commands
- `claude-migrate-project <old-path> <new-path>` - Migrate conversations when renaming/moving a project

**Example:** If you move a project from `/home/user/old-name` to `/home/user/new-name`:
```bash
claude-migrate-project /home/user/old-name /home/user/new-name
mv /home/user/old-name /home/user/new-name
```

## Troubleshooting

### "Repository not initialized" error
- Run `claude-sync-init` before using `claude-sync-push` or `claude-sync-pull`

### "Repository is encrypted but locked" error
- Restore your encryption key: `claude-restore-encryption-key`
- Then re-run `claude-sync-init` to unlock

### Conversations not appearing
- Restart Claude Code after `claude-sync-pull`
- Check permissions: `ls -la ~/.claude/projects`

### Git push fails
- Verify remote configured: `git remote -v`
- Check git credentials
- Ensure you have write access to repository

### Encryption key mismatch
- Ensure you're using the correct key from your password manager
- If key was lost, you'll need to start fresh with a new encrypted repo

### Configuration errors
- Run `claude-sync-status` to see current config
- Run `claude-config` to reconfigure
- Check `.claude-sync-config.local` exists

## Requirements

- Bash 4.0+
- Git
- rsync
- tar, gzip
- git-crypt (optional, for encryption)

**Supported platforms:**
- Linux (Ubuntu, Debian, Fedora, Arch, etc.)
- macOS
- Windows (WSL)

## Contributing

Contributions welcome! Please:
- Follow existing code style
- Update documentation
- Test on fresh install
- Ensure scripts return to original directory

## License

MIT License - see LICENSE file

## Support

- 🐛 [Report bugs](https://github.com/porkchop/claude-code-sync/issues)
- 💡 [Request features](https://github.com/porkchop/claude-code-sync/issues)
- 📖 [Read the docs](https://github.com/porkchop/claude-code-sync#readme)

## Acknowledgments

Built for the Claude Code community. Inspired by the need to work seamlessly across multiple development machines.
