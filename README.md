# install-jq-action
Multiplatform [jq](https://github.com/stedolan/jq) installer action

[![Tests - Setup jq Action](https://github.com/dcarbone/install-jq-action/actions/workflows/tests.yaml/badge.svg)](https://github.com/dcarbone/install-jq-action/actions/workflows/tests.yaml)

This action cannot currently handle MacOS arm64 runners.

# Index

1. [Examples](#examples)
2. [Action Source](action.yaml)
3. [Action Inputs](#action-inputs)
4. [Action Outputs](#action-outputs)

## Examples

* [linux](./.github/workflows/example-linux.yaml)
* [macos](./.github/workflows/example-macos.yaml)

## Action Inputs

#### version
```yaml
  version:
    required: false
    description: "Version of jq to install"
    default: "1.6"
```

This must be a version with a [corresponding release](https://github.com/stedolan/jq/releases).

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
Setting this to true can also help ensure the same version is used across both self-hosted and remote runners. 

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
