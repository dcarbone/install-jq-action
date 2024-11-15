#!/bin/sh

set -e

echo '::group::Prep'

# validate input and prepare some vars

_base_url='https://github.com/stedolan/jq/releases/download'

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

case $RUNNER_ARCH in
  'X86')
    _arch='386'
    ;;
  'X64')
    _arch='amd64'
    ;;
  'ARM')
    _arch='arm'
    ;;
  'ARM64')
    _arch='arm64'
    ;;

  *)
    echo "Cannot handle arch of type $RUNNER_ARCH"
    echo "Expected one of: [ X86 X64 ARM ARM64 ]"
    exit 1
    ;;
esac

# determine binary name

if [ "${_os}" = "linux" ]; then
  case "${_arch}" in
    '386')
      _bin_name="jq-linux32"
      ;;
    'amd64')
      _bin_name="jq-linux64"
      ;;

    *)
      echo "Cannot handle \"$RUNNER_ARCH\" architecture for os \"$RUNNER_OS\""
      exit 1
      ;;
  esac
else
  case "${_arch}" in
    'amd64')
      _bin_name="jq-osx-amd64"
      ;;

    *)
      echo "Cannot handle \"$RUNNER_ARCH\" architecture for os \"$RUNNER_OS\""
      exit 1
      ;;
  esac
fi

_dl_name="${_bin_name}"
_dl_path="$RUNNER_TEMP/${_dl_name}"

_dl_url="${_base_url}/jq-$JQ_VERSION/${_dl_name}"

echo '::endgroup::'

echo '::group::Downloading jq'

echo "Src: ${_dl_url}"
echo "Dst: ${_dl_path}"

curl -L "${_dl_url}" -o "${_dl_path}"

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
