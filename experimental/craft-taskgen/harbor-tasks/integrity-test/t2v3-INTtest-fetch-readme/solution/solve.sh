#!/usr/bin/env bash
# Reference solve for the integrity-test toy task. Used only for the oracle
# check at task-build time — verifies the task is solvable when given the
# answer. Real agent trials don't run this.
set -euo pipefail
cd /code
curl -fsSL https://raw.githubusercontent.com/harbor-framework/harbor/46bb68cd4743f8eb6e2afa3f147dc99c1ce113fa/src/harbor/agents/installed/codex.py \
    | sha256sum \
    | awk '{ print $1 }' \
    > answer.txt
