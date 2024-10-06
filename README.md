# Ansible Collections

[![GitHub issues](https://img.shields.io/github/issues/meysam81/ansible-collections)](https://github.com/meysam81/ansible-collections/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/meysam81/ansible-collections)](https://github.com/meysam81/ansible-collections/pulls)
[![GitHub](https://img.shields.io/github/license/meysam81/ansible-collections)](https://github.com/meysam81/ansible-collections/blob/main/LICENSE)
[![GitHub last commit](https://img.shields.io/github/last-commit/meysam81/ansible-collections)](https://github.com/meysam81/ansible-collections/commits/main)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Ansible Collections](#ansible-collections)
  - [Usage](#usage)
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

## License

This project is licensed under the Apache License 2.0 - see the
[LICENSE](LICENSE) file for details.
