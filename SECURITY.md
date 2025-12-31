# Security & Privacy

## What Gets Synced

The Claude Code sync system stores these files in your Bitbucket repository:

### Included (Synced)
- **Conversations** - Full text of all Claude Code conversations
  - Every message you send and receive
  - All code snippets discussed or generated
  - File paths and project structure
  - System information (OS, directories, etc.)
- **File History** - All file edits made during conversations
- **Todos** - Task lists from conversations
- **Command History** - Shell commands run via Claude Code

### Excluded (NOT Synced)
- `.credentials.json` - Your Claude API credentials
- Debug files
- Local backups (in `backups/` directory)

## Security Risks

### High Risk
1. **Bitbucket account compromise** - Conversations stored in plaintext
2. **Sensitive data in conversations** - API keys, passwords, secrets discussed
3. **Proprietary code** - All code from conversations is visible
4. **Business logic** - Architecture, algorithms, security discussions exposed

### Medium Risk
1. **Bitbucket data breach** - Unlikely but conversations would be exposed
2. **Accidental repository exposure** - If repo is made public
3. **Shared access** - Anyone with Bitbucket access can read

## Current Protection

✅ Private Bitbucket repository
✅ HTTPS transmission
✅ Credentials excluded from sync
❌ **No encryption at rest** - conversations stored in plaintext on Bitbucket

## Should You Enable Encryption?

**Yes, if you:**
- Work with proprietary/confidential code
- Discuss security vulnerabilities or exploits
- Handle customer data or business logic
- Work with blockchain/financial systems
- Discuss API keys, credentials, or secrets
- Want defense-in-depth security

**Maybe not, if:**
- Only working on personal/public projects
- Already careful about sensitive information
- Accept Bitbucket's security as sufficient
- Don't mind conversations being readable if account compromised

## Encryption Setup (Optional)

### Option 1: git-crypt (Recommended)

Transparently encrypts files in git repository. Files are encrypted on Bitbucket, decrypted automatically on your machines.

**Setup:**
```bash
# Install git-crypt (Ubuntu/PopOS)
sudo apt install git-crypt

# Navigate to repo
cd ~/dev/projects/aaron/claude

# Initialize git-crypt
git-crypt init

# Create encryption filter
echo "conversations/** filter=git-crypt diff=git-crypt" > .gitattributes
git add .gitattributes
git commit -m "Enable git-crypt for conversations"

# Export your encryption key (save this securely!)
git-crypt export-key ~/claude-git-crypt.key

# Lock the repo to test encryption
git-crypt lock
```

**Backup key to KeePass (recommended):**

The setup script will display the key in base64 format. Store it in KeePass as:

*Option 1: As attachment (easiest)*
1. Create KeePass entry: "Claude Code Git-Crypt Key"
2. Attach the file: `~/.claude-git-crypt.key`
3. Save

*Option 2: As text in notes*
1. Create KeePass entry: "Claude Code Git-Crypt Key"
2. Copy the base64 text and paste in Notes field
3. Save

**On additional machines:**

```bash
# Retrieve key from KeePass (run this helper)
claude-restore-encryption-key

# Then unlock the repo
cd ~/dev/projects/aaron/claude
git-crypt unlock ~/.claude-git-crypt.key
```

**Key Management:**
- **Recommended:** Store in KeePass (synced across your machines automatically)
- Alternative: Store in `~/aaron` if that's already secured
- Don't commit the key to the repo!
- Without the key, conversations CANNOT be decrypted

### Option 2: GPG Encryption

Use GPG to encrypt conversations before pushing.

**Pros:**
- No additional tools needed (GPG already common)
- Can use your existing GPG key

**Cons:**
- Requires manual encryption/decryption
- More complex workflow

### Option 3: Encrypted Git Remote

Use a git remote that supports encryption (e.g., git-remote-gcrypt).

**Pros:**
- Entire repo encrypted
- Bitbucket sees only encrypted blobs

**Cons:**
- More complex setup
- Requires additional tools on all machines

## Best Practices Regardless of Encryption

1. **Never discuss real secrets** - Don't paste actual API keys, passwords
2. **Use placeholders** - "sk-xxxxx" instead of real keys
3. **Review before committing** - Check what's being synced
4. **Rotate credentials** - If you accidentally sync a secret
5. **Regular audits** - Occasionally review what's in conversations/
6. **Use .gitignore** - Already configured to exclude credentials

## Recommendation

For your use case (blockchain development, bridge implementations, smart contracts):

**Enable git-crypt encryption** - It's transparent after setup and provides good security against Bitbucket compromise without changing your workflow.

The setup takes 5 minutes and gives you defense-in-depth security.
