# install-jq-action
Multiplatform [jq](https://github.com/jqlang/jq) installer action

[![Tests - Install jq Action](https://github.com/dcarbone/install-jq-action/actions/workflows/tests.yaml/badge.svg)](https://github.com/dcarbone/install-jq-action/actions/workflows/tests.yaml)

This action is tested against the following versions of jq:

**Modern releases (jqlang/jq — 1.7+)**
- [1.8.2](https://github.com/jqlang/jq/releases/tag/jq-1.8.2)
- [1.8.1](https://github.com/jqlang/jq/releases/tag/jq-1.8.1)
- [1.8.0](https://github.com/jqlang/jq/releases/tag/jq-1.8.0)
- [1.7.1](https://github.com/jqlang/jq/releases/tag/jq-1.7.1)
- [1.7](https://github.com/jqlang/jq/releases/tag/jq-1.7)

**Legacy releases (stedolan/jq — 1.5 and 1.6)**
- [1.6](https://github.com/stedolan/jq/releases/tag/jq-1.6)
- [1.5](https://github.com/stedolan/jq/releases/tag/jq-1.5)

# Index

1. [Examples](#examples)
2. [Action Source](action.yaml)
3. [Action Inputs](#action-inputs)
4. [Action Outputs](#action-outputs)
5. [Security](#security)

## Examples

* [linux](./.github/workflows/example-linux.yaml)
* [macos](./.github/workflows/example-macos.yaml)
* [windows](./.github/workflows/example-windows.yaml)

## Action Inputs

#### version
```yaml
  version:
    required: false
    description: "Version of jq to install"
    default: "1.8.2"
```

Must be a dot-separated numeric version string (e.g. `1.7.1`, `1.8.0`).

- **1.7 and newer** are downloaded from the [jqlang/jq](https://github.com/jqlang/jq/releases) repository and
  support a wider set of architectures: `amd64`, `arm64`, `armhf`, `armel`, and `i386`.
- **1.5 and 1.6** are downloaded from the legacy [stedolan/jq](https://github.com/stedolan/jq/releases) repository
  and support `linux32`, `linux64`, and `osx-amd64`.

#### force
```yaml
  force:
    required: false
    description: "If 'true', does not check for existing jq installation before continuing."
    default: 'false'
```

GitHub's own hosted runners come with a version of
[jq pre-installed](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners#preinstalled-software).

Setting this to `true` will install the version you specify into the tool cache, superseding the preinstalled version.
Setting this to `true` can also help ensure the same version is used across both self-hosted and remote runners.

## Action Outputs

#### found
```yaml
  found:
    description: "If 'true', jq was already found on this runner"
```

#### installed
```yaml
  installed:
    description: "If 'true', jq was installed by this action"
```

## Security

Starting with v4 this action performs integrity verification on every download:

- **jq 1.7 and newer**: the binary's SHA-256 digest is checked against the release's `sha256sum.txt` before it is
  installed. The install fails if the digest does not match. If no `sha256sum.txt` is published for a release
  (e.g. the original jq 1.7.0 tag) a warning is printed and installation continues.
- **jq 1.5 / 1.6 (legacy)**: no checksum file is published by the upstream `stedolan/jq` project, so no
  verification is performed.

`curl` is hardened with `--fail` so that HTTP error responses (4xx/5xx) abort the download rather than writing
the error page to disk as the binary.

All four install scripts validate the `version` input against the pattern `^[0-9]+\.[0-9]+(\.[0-9]+)*$` and
reject malformed values (including path-traversal attempts) before constructing any download URL.
