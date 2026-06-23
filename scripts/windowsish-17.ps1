$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Write-Host "::group::Prep"

if (-not ($Env:JQ_VERSION -match '^[0-9]+\.[0-9]+(\.[0-9]+)*$')) {
    Write-Host "Invalid JQ_VERSION: '$Env:JQ_VERSION'. Expected a version string like '1.7.1'."
    exit 1
}

$_base_url = "https://github.com/jqlang/jq/releases/download"

$_arch_env = ($Env:RUNNER_ARCH).ToLower()

# validate input and prepare some vars

switch ($_arch_env)
{
    "x86" {
        $_arch = "i386"
    }
    "386" {
        $_arch = "i386"
    }
    "x64" {
        $_arch = "amd64"
    }
    "x86_64" {
        $_arch = "amd64"
    }
    "amd64" {
        $_arch = "amd64"
    }
    default {
        Write-Host "Cannot handle arch of type $Env:RUNNER_ARCH"
        Write-Host "Expected one of: [ x86 386 x64 x86_64 amd64 ]"
        exit 1
    }
}

# build bin name
$_bin_name = "jq-windows-${_arch}.exe"

# build download vars

$_dl_name = "${_bin_name}"
$_dl_path = "$Env:RUNNER_TEMP\${_dl_name}"

$_dl_url = "${_base_url}/jq-$Env:JQ_VERSION/${_dl_name}"

Write-Host "::endgroup::"

# download artifact

Write-Host "::group::Downloading jq"

Write-Host "Src: ${_dl_url}"
Write-Host "Dst: ${_dl_path}"

Invoke-WebRequest -Uri "${_dl_url}" -OutFile "${_dl_path}"

Write-Host "::endgroup::"

Write-Host "::group::Verifying checksum"

$_sha_url = "${_base_url}/jq-$Env:JQ_VERSION/sha256sum.txt"
$_sha_path = "$Env:RUNNER_TEMP\jq-$Env:JQ_VERSION.sha256sum.txt"

$_sha_ok = $true
try {
    Invoke-WebRequest -Uri "${_sha_url}" -OutFile "${_sha_path}"
} catch {
    $_sha_ok = $false
    if ($_.Exception.Response -and ([int]$_.Exception.Response.StatusCode -eq 404)) {
        $_sha_ok = $false
    } else {
        Write-Host "Failed to download sha256sum.txt from ${_sha_url}"
        throw
    }
}

if ($_sha_ok -and (Test-Path -LiteralPath "${_sha_path}")) {
    $_expected = $null
    foreach ($_line in Get-Content -LiteralPath "${_sha_path}") {
        $_parts = $_line -split '\s+'
        if ($_parts.Length -ge 2 -and $_parts[1] -eq "${_bin_name}") {
            $_expected = $_parts[0]
            break
        }
    }
    if (-not $_expected) {
        Write-Host "Could not find checksum for '${_bin_name}' in ${_sha_url}"
        exit 1
    }
    $_actual = (Get-FileHash -Algorithm SHA256 -LiteralPath "${_dl_path}").Hash.ToLower()
    if ($_expected.ToLower() -ne $_actual) {
        Write-Host "Checksum verification failed for '${_bin_name}'"
        Write-Host "Expected: $_expected"
        Write-Host "Actual:   $_actual"
        exit 1
    }
    Write-Host "Checksum verified for '${_bin_name}'"
} else {
    Write-Host "WARNING: No sha256sum.txt found at ${_sha_url}; skipping checksum verification."
}

Write-Host "::endgroup::"

# install into tool cache

Write-Host "::group::Copying to tool cache"

Write-Host "Creating tool cache directory $Env:RUNNER_TOOL_CACHE\jq\"
New-Item "$Env:RUNNER_TOOL_CACHE\jq\" -ItemType Directory -Force

Write-Host "Installing into tool cache:"
Write-Host "Src: $Env:RUNNER_TEMP\${_bin_name}"
Write-Host "Dst: $Env:RUNNER_TOOL_CACHE\jq\jq.exe"
Move-Item -Force -LiteralPath "$Env:RUNNER_TEMP\${_bin_name}" -Destination "$Env:RUNNER_TOOL_CACHE\jq\jq.exe"

Write-Host "Adding $Env:RUNNER_TOOL_CACHE\jq\ to path..."
Add-Content "$Env:GITHUB_PATH" "$Env:RUNNER_TOOL_CACHE\jq\"

Write-Host "::endgroup::"
