# Check for secrets in current project

Useful for security audits before commits or code reviews.

## Usage

```bash
/check-secrets
```

## What it checks

- API keys and tokens
- Passwords and credentials
- Private keys and certificates
- Database connection strings
- Environment variable usage

## Files scanned

- All tracked files in git
- Unstaged changes
- Common config files (even if gitignored)

## Output

- Lists potential secrets found
- Shows file locations and line numbers
- Provides severity assessment
- Suggests remediation steps

⚠️  This is a defensive security tool for detecting accidental credential exposure.