#!/usr/bin/env bash
set -uo pipefail
mkdir -p /logs/verifier
if [ -d /tests/postmerge_tests ]; then
    find /tests/postmerge_tests -type f | while IFS= read -r f; do
        rel="${f#/tests/postmerge_tests/}"
        mkdir -p "/code/$(dirname "$rel")"
        cp "$f" "/code/$rel"
    done
fi
cd /code
python3 -m pytest -v --tb=no --continue-on-collection-errors \
    $(cat /tests/fail_to_pass.txt /tests/pass_to_pass.txt 2>/dev/null) \
    2>&1 | tee /logs/verifier/verify_full_output.txt || true
python3 /tests/score.py
