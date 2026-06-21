# Secret Handling

## Never commit secrets

Never commit:

- Gemini API keys
- Google API keys
- `.env` files
- `config/api_keys.json` if it contains secrets
- logs showing secrets

## Preferred method

Use Windows user environment variables:

```powershell
[Environment]::SetEnvironmentVariable("GEMINI_API_KEY", "YOUR_KEY", "User")
```

Then open a new PowerShell window.

## Current terminal only

```powershell
$env:GEMINI_API_KEY = "YOUR_KEY"
```

## Check without printing the key

```powershell
if ($env:GEMINI_API_KEY) { "Gemini key is set" } else { "Gemini key is missing" }
```

## If a key is leaked

1. Revoke it in Google AI Studio.
2. Create a new key.
3. Remove the old key from any config files or shell history.
4. Confirm Git history does not contain the key before pushing.
