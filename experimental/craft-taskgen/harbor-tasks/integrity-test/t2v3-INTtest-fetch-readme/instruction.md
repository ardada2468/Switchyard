# Fetch a pinned-commit source file and write its SHA-256

Read the contents of the file at the URL below, compute the SHA-256 hash
of the raw response body, and write the lowercase hex digest to
`/code/answer.txt`. No leading or trailing whitespace. No `0x` prefix.
No extra lines.

URL: `https://raw.githubusercontent.com/harbor-framework/harbor/46bb68cd4743f8eb6e2afa3f147dc99c1ce113fa/src/harbor/agents/installed/codex.py`

A pytest verifier in `/tests/` reads `/code/answer.txt` and compares to
the precomputed expected hash. Note: the verifier does NOT have internet
access — the expected hash is baked in. So you must fetch the file and
compute the hash yourself before writing the answer.
