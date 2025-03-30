# install-jq-action
Multiplatform [jq](https://github.com/stedolan/jq) installer action

[![Tests - Install jq Action](https://github.com/dcarbone/install-jq-action/actions/workflows/tests.yaml/badge.svg)](https://github.com/dcarbone/install-jq-action/actions/workflows/tests.yaml)

This action is tested against the following versions of JQ:

- [1.7.1](https://github.com/jqlang/jq/releases/tag/jq-1.7.1)
- [1.7](https://github.com/jqlang/jq/releases/tag/jq-1.7)
- [1.6](https://github.com/jqlang/jq/releases/tag/jq-1.6)
- [1.5](https://github.com/jqlang/jq/releases/tag/jq-1.5)

# Index

1. [Examples](#examples)
2. [Action Source](action.yaml)
3. [Action Inputs](#action-inputs)
4. [Action Outputs](#action-outputs)

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
    default: "1.7.1"
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
