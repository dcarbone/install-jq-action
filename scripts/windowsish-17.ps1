$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Write-Host "::group::Prep"

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

Write-Host "::group::Running choco uninstall jq"

choco uninstall jq

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
$(
    "$Env:RUNNER_TOOL_CACHE\jq\"
    Get-Content "$Env:GITHUB_PATH" -Raw
) | Set-Content "$Env:GITHUB_PATH"

Write-Host "::endgroup::"
