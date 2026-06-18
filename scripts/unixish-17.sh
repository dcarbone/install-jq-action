#!/bin/sh

set -e

echo '::group::Prep'

# validate input and prepare some vars

case "$JQ_VERSION" in
  ''|*[!0-9.]*)
    echo "Invalid JQ_VERSION: \"$JQ_VERSION\". Expected a version string like \"1.7.1\"."
    exit 1
    ;;
esac

# Portable SHA256 digest: prefer sha256sum (Linux), fall back to shasum
# (macOS, ships with the OS via Perl), then openssl. Prints only the hex
# digest and returns non-zero if no tool is available.
_compute_sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  elif command -v openssl >/dev/null 2>&1; then
    openssl dgst -sha256 "$1" | awk '{print $NF}'
  else
    return 1
  fi
}

_base_url='https://github.com/jqlang/jq/releases/download'

_arch_env="$(echo "$RUNNER_ARCH" | tr '[:upper:]' '[:lower:]')"

_os=
_arch=

_bin_name=
_dl_name=
_dl_path=
_dl_url=

case $RUNNER_OS in
  [Ll]inux)
    _os='linux'
    ;;
  mac[Oo][Ss])
    _os='macos'
    ;;

  *)
    echo "Cannot handle OS of type $RUNNER_OS"
    echo "Expected one of: [ Linux macOS ]"
    exit 1
    ;;
esac

case "${_arch_env}" in
  'x86'|'386')
    _arch='i386'
    ;;
  'x64'|'amd64'|'x86_64')
    _arch='amd64'
    ;;
  'arm'|'armhf')
    _arch='armhf'
    ;;
  'armel')
    _arch='armel'
    ;;
  'arm64'|'aarch64')
    _arch='arm64'
    ;;

  *)
    echo "Cannot handle arch of type $RUNNER_ARCH"
    echo "Expected one of: [ x86 386 x64 amd64 x86_64 arm armhf armel arm64 aarch64 ]"
    exit 1
    ;;
esac

# build bin name
_bin_name="jq-${_os}-${_arch}"

# build download vars
_dl_name="${_bin_name}"
_dl_path="$RUNNER_TEMP/${_dl_name}"

_dl_url="${_base_url}/jq-$JQ_VERSION/${_dl_name}"

echo '::endgroup::'

echo '::group::Downloading jq'

echo "Src: ${_dl_url}"
echo "Dst: ${_dl_path}"

curl -fsSL --retry 3 "${_dl_url}" -o "${_dl_path}"

echo '::endgroup::'

echo '::group::Verifying checksum'

_sha_url="${_base_url}/jq-$JQ_VERSION/sha256sum.txt"
_sha_path="$RUNNER_TEMP/jq-$JQ_VERSION.sha256sum.txt"

if curl -fsSL --retry 3 "${_sha_url}" -o "${_sha_path}"; then
  _expected="$(grep -E " ${_bin_name}\$" "${_sha_path}" | head -n1 | awk '{print $1}' || true)"
  if [ -z "${_expected}" ]; then
    echo "Could not find checksum for \"${_bin_name}\" in ${_sha_url}"
    exit 1
  fi
  _actual="$(_compute_sha256 "${_dl_path}")" || {
    echo "No SHA256 tool available (sha256sum, shasum, openssl)."
    exit 1
  }
  if [ "${_expected}" != "${_actual}" ]; then
    echo "Checksum verification failed for \"${_bin_name}\""
    echo "Expected: ${_expected}"
    echo "Actual:   ${_actual}"
    exit 1
  fi
  echo "Checksum verified for \"${_bin_name}\""
else
  echo "WARNING: No sha256sum.txt found at ${_sha_url}; skipping checksum verification."
fi

echo '::endgroup::'

echo '::group::Copying to tool cache'

echo "Creating tool cache directory $RUNNER_TOOL_CACHE/jq"
mkdir -p "$RUNNER_TOOL_CACHE/jq"

echo "Installing into tool cache:"
echo "Src: $RUNNER_TEMP/${_bin_name}"
echo "Dst: $RUNNER_TOOL_CACHE/jq/jq"
mv "$RUNNER_TEMP/${_bin_name}" "$RUNNER_TOOL_CACHE/jq/jq"

chmod +x "$RUNNER_TOOL_CACHE/jq/jq"

echo "Adding $RUNNER_TOOL_CACHE/jq to path..."
echo "$RUNNER_TOOL_CACHE/jq" >> $GITHUB_PATH

echo '::endgroup::'
