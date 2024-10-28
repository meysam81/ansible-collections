#!/usr/bin/env bash

set -eu

if ! command -v git-cliff &> /dev/null; then
    echo "git-cliff is not installed. Please install it by running 'cargo install git-cliff'." >&2
    exit 0
fi

git-cliff --config cliff.toml > CHANGELOG.md
