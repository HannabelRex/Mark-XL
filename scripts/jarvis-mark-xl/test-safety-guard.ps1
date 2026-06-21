$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $RepoRoot

# PowerShell 7 can convert native stderr into error records. Keep native command
# output capturable so we can report the actual Python failure instead of a
# misleading wrapper error.
if (Get-Variable PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue) {
    $PSNativeCommandUseErrorActionPreference = $false
}

$PreviousPythonPath = $env:PYTHONPATH
$PreviousSafetyEnable = $env:JARVIS_SAFETY_ENABLE
$PreviousSafetyMode = $env:JARVIS_SAFETY_MODE
$PreviousSafetyNonInteractive = $env:JARVIS_SAFETY_NONINTERACTIVE
$PreviousSafetyLog = $env:JARVIS_SAFETY_LOG

$LogDir = Join-Path $RepoRoot "logs"
$TestFile = Join-Path $LogDir "safety-test-delete.tmp"
$TestScript = Join-Path $LogDir "safety-test-delete.py"

try {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

    # Ensure Python can discover repo-root sitecustomize.py even when the test
    # script is executed from logs\. Without this, Python sets sys.path[0] to
    # logs and the safety bootstrap never loads.
    $PathSeparator = [System.IO.Path]::PathSeparator
    if ([string]::IsNullOrWhiteSpace($PreviousPythonPath)) {
        $env:PYTHONPATH = $RepoRoot
    } else {
        $env:PYTHONPATH = "$RepoRoot$PathSeparator$PreviousPythonPath"
    }

    $env:JARVIS_SAFETY_ENABLE = "1"
    $env:JARVIS_SAFETY_MODE = "block"
    $env:JARVIS_SAFETY_NONINTERACTIVE = "1"
    $env:JARVIS_SAFETY_LOG = Join-Path $LogDir "jarvis_safety_audit.log"

    Set-Content -Path $TestFile -Value "delete test" -Encoding UTF8

@'
import os
from pathlib import Path

# Import is harmless if sitecustomize already auto-loaded. It is useful here as
# a clear diagnostic if PYTHONPATH/bootstrap is broken.
try:
    import sitecustomize  # noqa: F401
except Exception as exc:
    raise SystemExit(f"sitecustomize import failed: {exc}")

p = Path("logs/safety-test-delete.tmp")
try:
    os.remove(p)
except PermissionError:
    print("BLOCKED")
else:
    raise SystemExit("Expected os.remove to be blocked")
'@ | Set-Content -Path $TestScript -Encoding UTF8

    $Output = & python $TestScript 2>&1
    $ExitCode = $LASTEXITCODE
    $OutputText = ($Output | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine

    if ($ExitCode -ne 0) {
        Write-Host $OutputText
        throw "Safety guard Python test failed."
    }
    if ($OutputText -notmatch "BLOCKED") {
        throw "Safety guard did not report BLOCKED. Output: $OutputText"
    }
    if (-not (Test-Path $TestFile)) {
        throw "Safety guard failed: test file was deleted."
    }

    Write-Host "Safety guard test passed." -ForegroundColor Green
}
finally {
    if ($null -eq $PreviousPythonPath) { Remove-Item Env:PYTHONPATH -ErrorAction SilentlyContinue } else { $env:PYTHONPATH = $PreviousPythonPath }
    if ($null -eq $PreviousSafetyEnable) { Remove-Item Env:JARVIS_SAFETY_ENABLE -ErrorAction SilentlyContinue } else { $env:JARVIS_SAFETY_ENABLE = $PreviousSafetyEnable }
    if ($null -eq $PreviousSafetyMode) { Remove-Item Env:JARVIS_SAFETY_MODE -ErrorAction SilentlyContinue } else { $env:JARVIS_SAFETY_MODE = $PreviousSafetyMode }
    if ($null -eq $PreviousSafetyNonInteractive) { Remove-Item Env:JARVIS_SAFETY_NONINTERACTIVE -ErrorAction SilentlyContinue } else { $env:JARVIS_SAFETY_NONINTERACTIVE = $PreviousSafetyNonInteractive }
    if ($null -eq $PreviousSafetyLog) { Remove-Item Env:JARVIS_SAFETY_LOG -ErrorAction SilentlyContinue } else { $env:JARVIS_SAFETY_LOG = $PreviousSafetyLog }

    Remove-Item $TestFile -Force -ErrorAction SilentlyContinue
    Remove-Item $TestScript -Force -ErrorAction SilentlyContinue
}
