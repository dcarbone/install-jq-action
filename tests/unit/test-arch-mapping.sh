#!/bin/sh
# Unit tests for RUNNER_ARCH → jq arch mapping used in unixish-17.sh.
#
# The mapping (after lowercasing RUNNER_ARCH) is:
#   x86 | 386        → i386
#   x64 | amd64 | x86_64 → amd64
#   arm | armhf      → armhf
#   armel            → armel
#   arm64 | aarch64  → arm64
#   anything else    → error (exit 1)
#
# Usage:
#   sh tests/unit/test-arch-mapping.sh
#
# Exit code:
#   0  — all tests passed
#   1  — one or more tests failed

set -e

_pass=0
_fail=0

# _map_arch <runner_arch>
# Prints the mapped jq arch string, or returns 1 on unsupported input.
_map_arch() {
  _arch_env="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
  case "${_arch_env}" in
    'x86'|'386')           echo 'i386'   ;;
    'x64'|'amd64'|'x86_64') echo 'amd64' ;;
    'arm'|'armhf')         echo 'armhf'  ;;
    'armel')               echo 'armel'  ;;
    'arm64'|'aarch64')     echo 'arm64'  ;;
    *)                     return 1      ;;
  esac
}

# assert_maps_to <runner_arch> <expected_jq_arch>
assert_maps_to() {
  _input="$1"
  _expected="$2"
  _actual="$(_map_arch "$_input" 2>/dev/null)" || true
  if [ "${_actual}" = "${_expected}" ]; then
    echo "PASS  '$_input' → '$_expected'"
    _pass=$((_pass + 1))
  else
    echo "FAIL  '$_input' → expected '$_expected', got '${_actual}'"
    _fail=$((_fail + 1))
  fi
}

# assert_unsupported <runner_arch>
assert_unsupported() {
  _input="$1"
  if _map_arch "$_input" >/dev/null 2>&1; then
    echo "FAIL  '$_input' should be unsupported (was accepted)"
    _fail=$((_fail + 1))
  else
    echo "PASS  '$_input' → (unsupported, correctly rejected)"
    _pass=$((_pass + 1))
  fi
}

echo "=== Arch mapping unit tests (unixish-17.sh) ==="
echo ""

echo "--- Supported arch inputs ---"
assert_maps_to "X86"    "i386"
assert_maps_to "x86"    "i386"
assert_maps_to "386"    "i386"
assert_maps_to "X64"    "amd64"
assert_maps_to "x64"    "amd64"
assert_maps_to "amd64"  "amd64"
assert_maps_to "x86_64" "amd64"
assert_maps_to "ARM"    "armhf"
assert_maps_to "arm"    "armhf"
assert_maps_to "armhf"  "armhf"
assert_maps_to "ARMHF"  "armhf"
assert_maps_to "armel"  "armel"
assert_maps_to "ARMEL"  "armel"
assert_maps_to "ARM64"  "arm64"
assert_maps_to "arm64"  "arm64"
assert_maps_to "aarch64" "arm64"
assert_maps_to "AARCH64" "arm64"

echo ""
echo "--- Unsupported arch inputs ---"
assert_unsupported ""
assert_unsupported "mips"
assert_unsupported "riscv64"
assert_unsupported "s390x"
assert_unsupported "ppc64"

echo ""
echo "=== Results: ${_pass} passed, ${_fail} failed ==="

if [ "${_fail}" -gt 0 ]; then
  exit 1
fi
