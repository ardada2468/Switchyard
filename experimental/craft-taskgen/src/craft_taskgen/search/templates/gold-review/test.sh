#!/usr/bin/env bash
set -euo pipefail
mkdir -p /logs/verifier
python3 /tests/test_runner.py
exit 0
