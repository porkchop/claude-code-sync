# Configuration Guide

## Quick Start

Run the interactive configuration wizard:
```bash
claude-config
```

This creates `.claude-sync-config.local` with your settings.

## Configuration Layers

Settings are loaded in this priority order (highest to lowest):

1. **Environment Variables** (`CLAUDE_SYNC_*`)
   - Highest priority
   - Temporary overrides
   - Set in your shell: `export CLAUDE_SYNC_VERBOSE="true"`

2. **Local Config** (`.claude-sync-config.local`)
   - Machine-specific settings
   - **Gitignored** - not synced between machines
   - Created by `claude-config`

3. **Shared Config** (`.claude-sync-config`)
   - Default settings
   - Version controlled - synced to all machines
   - Can be customized for team/project defaults

4. **Built-in Defaults**
   - Fallback values if nothing else is configured

## Available Settings

### Required
- `CLAUDE_SYNC_REMOTE` - Git remote URL
  - Example: `git@bitbucket.org:user/repo.git`
  - Example: `https://github.com/user/repo.git`
  - **Must be configured** before first sync

### Optional
- `CLAUDE_SYNC_BRANCH` - Git branch (default: `main`)
- `CLAUDE_SYNC_ENCRYPTION` - Enable encryption (default: `false`)
- `CLAUDE_BACKUP_RETENTION_DAYS` - Auto-cleanup old backups (default: `30`)
- `CLAUDE_DATA_DIR` - Claude data directory (default: `$HOME/.claude`)
- `CLAUDE_SYNC_VERBOSE` - Verbose output (default: `false`)

## Examples

### Example 1: Basic Setup

Create `.claude-sync-config.local`:
```bash
CLAUDE_SYNC_REMOTE="git@bitbucket.org:myuser/claude-sync.git"
```

That's it! Everything else uses defaults.

### Example 2: With Encryption

```bash
CLAUDE_SYNC_REMOTE="git@bitbucket.org:myuser/claude-sync.git"
CLAUDE_SYNC_ENCRYPTION="true"
```

### Example 3: Custom Data Directory

```bash
CLAUDE_SYNC_REMOTE="git@github.com:myuser/claude-sync.git"
CLAUDE_SYNC_BRANCH="dev"
CLAUDE_DATA_DIR="/opt/claude-data"
CLAUDE_BACKUP_RETENTION_DAYS="60"
```

### Example 4: Using Environment Variables

Temporary override for testing:
```bash
export CLAUDE_SYNC_VERBOSE="true"
claude-sync-push
```

Permanent in `~/.bashrc`:
```bash
export CLAUDE_SYNC_REMOTE="git@bitbucket.org:myuser/claude-sync.git"
export PATH="$HOME/claude-code-sync:$PATH"
```

## Viewing Current Configuration

Check what settings are active:
```bash
claude-sync-status
```

This shows:
- Current configuration values
- Git repository status
- Conversation counts
- Available commands

## Managing Configuration

### Create/Edit Configuration
```bash
claude-config
```

### View Configuration Files
```bash
# Local (machine-specific, gitignored)
cat .claude-sync-config.local

# Shared (defaults, version controlled)
cat .claude-sync-config

# Template with all options documented
cat .claude-sync-config.example
```

### Reset Configuration
Delete local config to start fresh:
```bash
rm .claude-sync-config.local
claude-config
```

## Multi-Machine Setup

### Machine 1 (Initial Setup)
```bash
claude-config  # Set remote URL
claude-sync-push
```

### Machine 2, 3, etc.
```bash
git clone <repo-url> ~/claude-code-sync
cd ~/claude-code-sync
claude-config  # Use same remote URL
claude-sync-pull
claude-sync-push
```

The `.local` config is machine-specific and gitignored, so each machine has its own settings file that doesn't conflict.

## Troubleshooting

### Error: CLAUDE_SYNC_REMOTE not configured
Run `claude-config` or manually create `.claude-sync-config.local`:
```bash
echo 'CLAUDE_SYNC_REMOTE="git@bitbucket.org:user/repo.git"' > .claude-sync-config.local
```

### Which config file is being used?
Check with:
```bash
claude-sync-status
```

### Environment variable not taking effect?
Environment variables have highest priority. Make sure they're exported:
```bash
export CLAUDE_SYNC_VERBOSE="true"  # Not just CLAUDE_SYNC_VERBOSE="true"
```

## Advanced Usage

### Project-Specific Remotes

Use different remotes for different projects by setting environment variables:
```bash
# Project A
export CLAUDE_SYNC_REMOTE="git@bitbucket.org:team-a/claude-sync.git"
claude-sync-push

# Project B
export CLAUDE_SYNC_REMOTE="git@bitbucket.org:team-b/claude-sync.git"
claude-sync-push
```

### Shared Team Config

Commit custom defaults to `.claude-sync-config`:
```bash
# .claude-sync-config (committed to git)
CLAUDE_SYNC_BRANCH="team-conversations"
CLAUDE_BACKUP_RETENTION_DAYS="90"

# Each team member's .claude-sync-config.local
CLAUDE_SYNC_REMOTE="git@bitbucket.org:team/shared-convos.git"
```

### Testing Configuration

Test with verbose output without changing config:
```bash
CLAUDE_SYNC_VERBOSE="true" claude-sync-push
```
