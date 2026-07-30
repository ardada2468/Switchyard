#!/usr/bin/env bash
set -uo pipefail
mkdir -p /logs/verifier

# Overlay postmerge tests on /code/ if present (matches v2b convention)
if [ -d /tests/postmerge_tests ]; then
    find /tests/postmerge_tests -type f | while IFS= read -r f; do
        rel="${f#/tests/postmerge_tests/}"
        mkdir -p "/code/$(dirname "$rel")"
        cp "$f" "/code/$rel"
    done
fi

# Copy our verifier test file into /code/ (the agent doesn't see it during
# its turn; it gets dropped here just before pytest runs).
mkdir -p /code/tests
cp /tests/test_answer.py /code/tests/test_answer.py

cd /code
python3 -m pytest -v --tb=no --continue-on-collection-errors \
    $(cat /tests/fail_to_pass.txt /tests/pass_to_pass.txt 2>/dev/null) \
    2>&1 | tee /logs/verifier/verify_full_output.txt || true
python3 /tests/score.py
