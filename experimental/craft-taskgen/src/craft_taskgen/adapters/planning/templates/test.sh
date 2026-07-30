#!/usr/bin/env bash
set -euo pipefail
mkdir -p /logs/verifier
python3 /tests/test_runner.py
python3 /tests/score.py
exit 0
