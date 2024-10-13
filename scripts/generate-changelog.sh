#!/usr/bin/env bash

set -eu

git-cliff --verbose --config cliff.toml | tee CHANGELOG.md
