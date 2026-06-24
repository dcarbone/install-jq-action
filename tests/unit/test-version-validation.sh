#!/bin/sh
# Unit tests for JQ_VERSION input validation.
#
# Tests the regex used in unixish.sh and unixish-17.sh:
#   ^[0-9]+\.[0-9]+(\.[0-9]+)*$
#
# Usage:
#   sh tests/unit/test-version-validation.sh
#
# Exit code:
#   0  — all tests passed
#   1  — one or more tests failed

set -e

_pass=0
_fail=0

# _validate_version <version>
# Returns 0 (valid) or 1 (invalid), matching the logic in the install scripts.
_validate_version() {
  printf '%s' "$1" | grep -Eq '^[0-9]+\.[0-9]+(\.[0-9]+)*$'
}

# assert_valid <version>
# Asserts that the version string is accepted by the validator.
assert_valid() {
  _v="$1"
  if _validate_version "$_v"; then
    echo "PASS  valid:   '$_v'"
    _pass=$((_pass + 1))
  else
    echo "FAIL  valid:   '$_v'  (was unexpectedly rejected)"
    _fail=$((_fail + 1))
  fi
}

# assert_invalid <version>
# Asserts that the version string is rejected by the validator.
assert_invalid() {
  _v="$1"
  if _validate_version "$_v"; then
    echo "FAIL  invalid: '$_v'  (was unexpectedly accepted)"
    _fail=$((_fail + 1))
  else
    echo "PASS  invalid: '$_v'"
    _pass=$((_pass + 1))
  fi
}

echo "=== Version validation unit tests ==="
echo ""

echo "--- Valid version strings ---"
assert_valid "1.5"
assert_valid "1.6"
assert_valid "1.7"
assert_valid "1.7.1"
assert_valid "1.8.0"
assert_valid "2.0"
assert_valid "2.0.0"
assert_valid "10.20.30"
assert_valid "1.2.3.4"

echo ""
echo "--- Invalid version strings ---"
assert_invalid ""
assert_invalid "."
assert_invalid ".."
assert_invalid "1"
assert_invalid "1."
assert_invalid ".7"
assert_invalid "1..7"
assert_invalid "1.7."
assert_invalid "1.7.1."
assert_invalid "abc"
assert_invalid "a.b.c"
assert_invalid "1.6-dirty"
assert_invalid "1.6 "
assert_invalid " 1.6"
assert_invalid "1 7"
assert_invalid "../../etc/passwd"
assert_invalid "../1.7"
assert_invalid "1.7/../etc"
assert_invalid "-n"
assert_invalid "-1.7"
assert_invalid "1.-7"

echo ""
echo "=== Results: ${_pass} passed, ${_fail} failed ==="

if [ "${_fail}" -gt 0 ]; then
  exit 1
fi
