# env_check.ps1 — Phase 0 environment pre-flight (Windows-native)
#
# Emits a concise one-line-per-check status to stdout. Designed to be called by
# the SessionStart hook, which captures this output. It is a READINESS INDICATOR,
# not a gate: it must never throw or exit non-zero for a "missing" tool — it only
# reports. Keep it fast and side-effect-free.
#
# flutter-ui-kit is a pure Dart/Flutter package whose SDK is managed by puro
# (~/.puro/envs/stable/flutter). puro's PATH shims can be unreliable on Windows, so
# for flutter/dart we try PATH first and fall back to the puro binary directly.

$ErrorActionPreference = 'Continue'

$PuroBin = Join-Path $HOME '.puro\envs\stable\flutter\bin'

function Test-Tool {
    param(
        [string]$Name,
        [string]$Command,
        [string]$VersionArg = '--version',
        [string[]]$FallbackPaths = @()
    )
    # 1) Try the command on PATH.
    try {
        $cmd = Get-Command $Command -ErrorAction Stop
        $ver = (& $cmd.Source $VersionArg 2>$null | Select-Object -First 1)
        Write-Output ("  {0}: OK ({1})" -f $Name, ($ver -replace '\s+', ' ').Trim())
        return
    } catch { }
    # 2) Fall back to explicit paths (e.g. the puro-managed binary).
    foreach ($p in $FallbackPaths) {
        if (Test-Path $p) {
            try {
                $ver = (& $p $VersionArg 2>$null | Select-Object -First 1)
                Write-Output ("  {0}: OK via puro ({1})" -f $Name, ($ver -replace '\s+', ' ').Trim())
                return
            } catch { }
        }
    }
    Write-Output ("  {0}: MISSING" -f $Name)
}

Write-Output "Environment check:"
Test-Tool -Name 'Flutter' -Command 'flutter' -FallbackPaths @((Join-Path $PuroBin 'flutter.bat'))
Test-Tool -Name 'Dart'    -Command 'dart'    -FallbackPaths @((Join-Path $PuroBin 'dart.bat'))
Test-Tool -Name 'Git'     -Command 'git'

# Always succeed: this is a reporting pre-flight, never a gate.
exit 0
