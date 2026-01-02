#!/bin/bash
# Claude Code Sync - Shared Library Functions
# Source this file in other scripts to load configuration

# Load configuration with proper precedence
load_config() {
    local SCRIPT_DIR="$1"
 
    # Set defaults (env vars preserved via ${:-} syntax in config files)
    CLAUDE_SYNC_REMOTE="${CLAUDE_SYNC_REMOTE:-}"
    CLAUDE_SYNC_BRANCH="${CLAUDE_SYNC_BRANCH:-main}"
    CLAUDE_SYNC_ENCRYPTION="${CLAUDE_SYNC_ENCRYPTION:-false}"
    CLAUDE_BACKUP_RETENTION_DAYS="${CLAUDE_BACKUP_RETENTION_DAYS:-30}"
    CLAUDE_DATA_DIR="${CLAUDE_DATA_DIR:-$HOME/.claude}"
    CLAUDE_SYNC_VERBOSE="${CLAUDE_SYNC_VERBOSE:-false}"
    CLAUDE_SYNC_COMMIT_MSG="${CLAUDE_SYNC_COMMIT_MSG:-Sync conversations - {date} {time} - {hostname}}"

    # Load shared config if exists (won't override env vars due to ${:-} syntax)
    if [ -f "$SCRIPT_DIR/.claude-sync-config" ]; then
        source "$SCRIPT_DIR/.claude-sync-config"
    fi

    # Load local config if exists (won't override env vars due to ${:-} syntax)
    if [ -f "$SCRIPT_DIR/.claude-sync-config.local" ]; then
        source "$SCRIPT_DIR/.claude-sync-config.local"
    fi
}

# Validate required configuration
validate_config() {
    local errors=0

    if [ -z "$CLAUDE_SYNC_REMOTE" ]; then
        echo "Error: CLAUDE_SYNC_REMOTE not configured."
        echo ""
        echo "Set it by:"
        echo "  1. Running: claude-config"
        echo "  2. Or set environment variable: export CLAUDE_SYNC_REMOTE=\"git@bitbucket.org:user/repo.git\""
        echo "  3. Or edit: .claude-sync-config.local"
        echo ""
        errors=1
    fi

    if [ ! -d "$CLAUDE_DATA_DIR" ]; then
        echo "Error: Claude data directory not found: $CLAUDE_DATA_DIR"
        echo ""
        echo "Claude Code may not have been used yet on this machine."
        echo "Or set CLAUDE_DATA_DIR to the correct location."
        echo ""
        errors=1
    fi

    return $errors
}

# Show current configuration (for debugging)
show_config() {
    echo "Current configuration:"
    echo "  Remote: ${CLAUDE_SYNC_REMOTE:-<not set>}"
    echo "  Branch: $CLAUDE_SYNC_BRANCH"
    echo "  Encryption: $CLAUDE_SYNC_ENCRYPTION"
    echo "  Data directory: $CLAUDE_DATA_DIR"
    echo "  Backup retention: $CLAUDE_BACKUP_RETENTION_DAYS days"
}

# Verbose output helper
log_verbose() {
    if [ "$CLAUDE_SYNC_VERBOSE" = "true" ]; then
        echo "$@"
    fi
}
