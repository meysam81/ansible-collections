# Ansible Collections

[![CI](https://img.shields.io/github/actions/workflow/status/meysam81/ansible-collections/ci.yml?branch=main&label=CI&logo=githubactions&logoColor=white&style=flat-square)](https://github.com/meysam81/ansible-collections/actions/workflows/ci.yml)
[![GitHub Release](https://img.shields.io/github/v/release/meysam81/ansible-collections?logo=github&style=flat-square)](https://github.com/meysam81/ansible-collections/releases/latest)
[![License](https://img.shields.io/github/license/meysam81/ansible-collections?style=flat-square)](https://github.com/meysam81/ansible-collections/blob/main/LICENSE)
[![Renovate](https://img.shields.io/badge/renovate-enabled-1f8b4c?logo=renovatebot&logoColor=white&style=flat-square)](https://developer.mend.io/github/meysam81/ansible-collections)
[![Last Commit](https://img.shields.io/github/last-commit/meysam81/ansible-collections?logo=github&style=flat-square)](https://github.com/meysam81/ansible-collections/commits/main)
[![Issues](https://img.shields.io/github/issues/meysam81/ansible-collections?logo=github&style=flat-square)](https://github.com/meysam81/ansible-collections/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/meysam81/ansible-collections?logo=github&style=flat-square)](https://github.com/meysam81/ansible-collections/pulls)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Ansible Collections](#ansible-collections)
  - [Usage](#usage)
  - [Release Instructions](#release-instructions)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

A collection of often personally used Ansible roles and playbooks.

These tend to be useful for my own use case and projects but feel free to open
a PR or an issue in case you want anything specific added.

## Usage

To use this collection, you can add it as a dependency in your `requirements.yml`
file:

```yaml
collections:
  - name: meysam81.general
    # latest version: https://github.com/meysam81/ansible-collections/releases
    version: x.x.x
```

## Release Instructions

```shell
version=vx.x.x
git tag -s $version -m $version
git push origin --tags
```

## License

This project is licensed under the Apache License 2.0 - see the
[LICENSE](LICENSE) file for details.
