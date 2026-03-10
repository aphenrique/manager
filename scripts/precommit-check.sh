#!/usr/bin/env bash
# Mirror of `mix precommit` alias — use for git pre-commit hooks or CI
# To install as git hook: ln -s ../../scripts/precommit-check.sh .git/hooks/pre-commit
set -e

MIX_ENV=test mix compile --warnings-as-errors
MIX_ENV=test mix deps.unlock --unused
mix format
MIX_ENV=test mix test
