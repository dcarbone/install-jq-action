#!/usr/bin/env bash

set -e

echo '::group::Prep'

# validate input and prepare some vars

_base_url='https://github.com/jqlang/jq/releases/download'

_arch_env="$(echo "$RUNNER_ARCH" | tr '[:upper:]' '[:lower:]')"

_os=
_arch=

_bin_name=
_dl_name=
_dl_path=
_dl_url=

case $RUNNER_OS in
  Linux)
    _os='linux'
    ;;
  macOS)
    _os='osx'
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

wget -O- "${_dl_url}" > "${_dl_path}"

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
