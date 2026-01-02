# Contributing to Claude Code Sync

Thank you for your interest in contributing to Claude Code Sync! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/claude-code-sync.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes thoroughly
6. Submit a pull request

## Development Guidelines

### Code Style

- Follow existing bash script conventions
- Use `set -e` for error handling
- Always save and restore `ORIGINAL_DIR` in scripts
- Use configuration variables from `lib-claude-sync.sh` (never hardcode paths)
- Add helpful error messages with next steps
- Include `--version` support in new commands

### Testing

Before submitting a PR, test on:
- Fresh install (no `~/.claude` exists)
- Existing conversations (merge scenario)
- With encryption enabled
- With non-standard `CLAUDE_DATA_DIR`

### Adding New Features

When adding new commands:
1. Source `lib-claude-sync.sh` for configuration
2. Add `--version` flag support (check existing commands for pattern)
3. Save/restore `ORIGINAL_DIR` (return user to starting directory)
4. Use `$CLAUDE_DATA_DIR` instead of hardcoded `~/.claude`
5. Make script executable: `chmod +x claude-new-command`
6. Update `README.md` with command documentation
7. Update `CLAUDE.md` with development notes
8. Update `CHANGELOG.md` with changes

### Configuration Variables

Always use these variables from config:
- `$CLAUDE_DATA_DIR` - Claude's data directory
- `$CLAUDE_SYNC_REMOTE` - Git remote URL
- `$CLAUDE_SYNC_BRANCH` - Git branch
- `$CLAUDE_SYNC_ENCRYPTION` - Encryption enabled?
- `$CLAUDE_BACKUP_RETENTION_DAYS` - Backup retention
- `$CLAUDE_SYNC_VERBOSE` - Verbose output

### Documentation

- Update `README.md` for user-facing changes
- Update `CLAUDE.md` for development context
- Update `CHANGELOG.md` for all changes
- Include examples in documentation

## Release Process

This project uses [Semantic Versioning](https://semver.org/) (SemVer):
- **MAJOR**: Breaking changes (incompatible API changes, config format changes)
- **MINOR**: New features (backwards compatible)
- **PATCH**: Bug fixes and small improvements

### Creating a Release

We provide a helper script to streamline the release process:

#### 1. Ensure Clean Working Tree

```bash
git status
# Commit any pending changes first
```

#### 2. Run Release Helper

For patch release (bug fixes):
```bash
./claude-release patch
```

For minor release (new features):
```bash
./claude-release minor
```

For major release (breaking changes):
```bash
./claude-release major
```

Or specify exact version:
```bash
./claude-release 1.2.3
```

#### 3. What the Script Does

The `claude-release` script will:
1. Read current version from `VERSION` file
2. Calculate or use the new version number
3. Update `VERSION` file
4. Add new section to `CHANGELOG.md`
5. Prompt you to edit the changelog
6. Create a git commit: `Release vX.Y.Z`
7. Create a git tag: `vX.Y.Z`

#### 4. Update CHANGELOG.md

Edit `CHANGELOG.md` to document changes in the new release:

```markdown
## [1.2.0] - 2026-01-15

### Added
- New feature X that does Y
- Support for platform Z

### Changed
- Improved performance of sync operation
- Updated documentation for clarity

### Fixed
- Fixed bug where X would fail when Y
- Corrected typo in error message
```

#### 5. Push to Remote

```bash
# Push commits and tags
git push origin master --tags
```

#### 6. Create GitHub Release (Optional)

Using GitHub CLI:
```bash
gh release create v1.2.0 \
  --title "Version 1.2.0" \
  --notes-file CHANGELOG.md
```

Or manually on GitHub:
1. Go to https://github.com/porkchop/claude-code-sync/releases/new
2. Select the tag you just created
3. Copy the changelog section for this version
4. Publish release

### Manual Release (Without Helper Script)

If you prefer to release manually:

1. **Update VERSION file:**
   ```bash
   echo "1.2.0" > VERSION
   ```

2. **Update CHANGELOG.md:**
   Add new section at the top with today's date and changes

3. **Commit changes:**
   ```bash
   git add VERSION CHANGELOG.md
   git commit -m "Release v1.2.0"
   ```

4. **Create tag:**
   ```bash
   git tag -a v1.2.0 -m "Version 1.2.0"
   ```

5. **Push:**
   ```bash
   git push origin master --tags
   ```

## Version Numbering Examples

- `1.0.0` → `1.0.1` (patch): Bug fix in backup script
- `1.0.0` → `1.1.0` (minor): Added new command `claude-migrate-project`
- `1.0.0` → `2.0.0` (major): Changed config file format (breaking change)

## Testing Releases

Before releasing:

1. **Test on clean system:**
   ```bash
   # Remove existing setup
   rm -rf ~/.claude-sync-test
   # Test fresh installation
   ```

2. **Test version flag:**
   ```bash
   ./claude-sync-push --version
   ./claude-backup --version
   # Should show new version
   ```

3. **Test existing workflows:**
   - Fresh setup
   - Sync with encryption
   - Backup and restore
   - Multi-machine sync

## Pull Request Guidelines

### PR Title

Use conventional commit format:
- `feat: add support for Windows WSL`
- `fix: correct tar exclusion for custom data dir`
- `docs: update configuration examples`
- `refactor: simplify encryption key handling`

### PR Description

Include:
- What: Brief description of changes
- Why: Reason for the change
- How: How you implemented it
- Testing: How you tested it

### Example PR Description

```markdown
## What
Adds support for Windows WSL platform.

## Why
Many users run Claude Code in WSL and want to sync conversations.

## How
- Added WSL detection in configuration
- Updated documentation with WSL-specific instructions
- Added git-crypt installation for Ubuntu on WSL

## Testing
- Tested on WSL 2 with Ubuntu 20.04
- Verified sync works between WSL and native Linux
- Tested encryption key restoration
```

## Code Review

All PRs require:
- No breaking changes (unless major version bump)
- Tests pass (manual testing currently)
- Documentation updated
- Code follows existing style
- Scripts return to original directory
- Helpful error messages

## Questions?

- Open an issue: https://github.com/porkchop/claude-code-sync/issues
- Read the docs: https://github.com/porkchop/claude-code-sync#readme
- Check CLAUDE.md for development context

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
