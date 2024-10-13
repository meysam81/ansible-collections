#!/usr/bin/env bash

set -eu

git-cliff --config cliff.toml > CHANGELOG.md
