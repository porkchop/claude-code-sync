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

# Show version from VERSION file
show_version() {
    local SCRIPT_DIR="$1"
    local COMMAND_NAME="$2"

    if [ -f "$SCRIPT_DIR/VERSION" ]; then
        local VERSION=$(cat "$SCRIPT_DIR/VERSION")
        echo "$COMMAND_NAME version $VERSION"
    else
        echo "$COMMAND_NAME version unknown (VERSION file not found)"
    fi
}

# Merge two JSONL files, keeping all unique lines from both
# Usage: merge_jsonl <file1> <file2> <output>
# Deduplicates and sorts by timestamp to maintain conversation order
merge_jsonl() {
    local file1="$1"
    local file2="$2"
    local output="$3"

    # Handle missing files gracefully
    if [ ! -f "$file1" ] && [ ! -f "$file2" ]; then
        return 0
    elif [ ! -f "$file1" ]; then
        cp "$file2" "$output"
        return 0
    elif [ ! -f "$file2" ]; then
        if [ "$file1" != "$output" ]; then
            cp "$file1" "$output"
        fi
        return 0
    fi

    # Both files exist - merge them
    local tmpfile=$(mktemp)

    # Combine both files, deduplicate, and sort by timestamp
    # Uses Python for reliable JSON parsing and timestamp sorting
    cat "$file1" "$file2" | python3 -c "
import sys, json

seen = set()
lines = []
for line in sys.stdin:
    line = line.strip()
    if not line or line in seen:
        continue
    seen.add(line)
    try:
        obj = json.loads(line)
        ts = obj.get('timestamp', '')
        lines.append((ts, line))
    except:
        lines.append(('', line))

# Sort by timestamp
lines.sort(key=lambda x: x[0])
for ts, line in lines:
    print(line)
" > "$tmpfile"

    mv "$tmpfile" "$output"
    log_verbose "  Merged: $(wc -l < "$file1") + $(wc -l < "$file2") -> $(wc -l < "$output") lines"
}

# Smart sync for a directory of JSONL files
# Merges each file instead of overwriting
# Usage: sync_jsonl_dir <source_dir> <dest_dir>
sync_jsonl_dir() {
    local src_dir="$1"
    local dest_dir="$2"

    if [ ! -d "$src_dir" ]; then
        return 0
    fi

    mkdir -p "$dest_dir"

    # Process each file in source
    find "$src_dir" -type f -name "*.jsonl" | while read src_file; do
        local relpath="${src_file#$src_dir/}"
        local dest_file="$dest_dir/$relpath"
        local dest_subdir=$(dirname "$dest_file")

        mkdir -p "$dest_subdir"

        if [ -f "$dest_file" ]; then
            # Both exist - merge
            merge_jsonl "$dest_file" "$src_file" "$dest_file"
        else
            # Only source exists - copy
            cp "$src_file" "$dest_file"
        fi
    done

    # Also copy any files from dest that don't exist in source (preserve remote-only files)
    find "$dest_dir" -type f -name "*.jsonl" | while read dest_file; do
        local relpath="${dest_file#$dest_dir/}"
        local src_file="$src_dir/$relpath"

        if [ ! -f "$src_file" ]; then
            log_verbose "  Keeping remote-only: $relpath"
        fi
    done
}

# Consolidate conversation files that share the same sessionId
# Merges them into the canonical file (filename matches sessionId)
# Usage: consolidate_sessions <projects_dir>
consolidate_sessions() {
    local projects_dir="$1"

    if [ ! -d "$projects_dir" ]; then
        return 0
    fi

    python3 << PYTHON_SCRIPT
import os
import json
from collections import defaultdict
from pathlib import Path

projects_dir = Path("$projects_dir")
consolidated_count = 0

for project_dir in projects_dir.iterdir():
    if not project_dir.is_dir():
        continue

    session_files = defaultdict(list)

    for jsonl_file in project_dir.glob('*.jsonl'):
        if jsonl_file.name.startswith('agent-'):
            continue

        try:
            messages = []
            session_id = None
            with open(jsonl_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        obj = json.loads(line)
                        # Keep looking for sessionId until we find one
                        if session_id is None and obj.get('sessionId'):
                            session_id = obj.get('sessionId')
                        messages.append(obj)
                    except:
                        continue

            if session_id:
                session_files[session_id].append((jsonl_file, messages))
        except:
            continue

    for session_id, files_and_messages in session_files.items():
        if len(files_and_messages) <= 1:
            continue

        canonical_file = None
        canonical_messages = []
        other_files = []

        for filepath, messages in files_and_messages:
            if filepath.stem == session_id:
                canonical_file = filepath
                canonical_messages = messages
            else:
                other_files.append((filepath, messages))

        if not canonical_file:
            canonical_file, canonical_messages = files_and_messages[0]
            other_files = files_and_messages[1:]

        if not other_files:
            continue

        all_messages = {json.dumps(m, sort_keys=True): m for m in canonical_messages}
        for other_file, other_messages in other_files:
            for msg in other_messages:
                key = json.dumps(msg, sort_keys=True)
                if key not in all_messages:
                    all_messages[key] = msg

        merged = list(all_messages.values())
        merged.sort(key=lambda x: x.get('timestamp', ''))

        with open(canonical_file, 'w') as f:
            for msg in merged:
                f.write(json.dumps(msg) + '\\n')

        for other_file, _ in other_files:
            other_file.unlink()

        consolidated_count += 1

if consolidated_count > 0:
    print(f"  Consolidated {consolidated_count} session(s)")
PYTHON_SCRIPT
}
