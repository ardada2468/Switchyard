# PR-First Mining: `base_sha` + `sha` from GitHub PRs

**Date:** 2026-04-15
**Status:** Approved

## Problem

The current `miner.py` walks git commits to find task candidates. Each candidate has a `sha` (commit SHA) but no `base_sha`. The downstream pipeline (`select_candidates` in `steps.py` line 98) does a direct key access `c["base_sha"]` — a `KeyError` if the field is absent — followed by a guard that rejects empty values. The pipeline was designed for PR-based input; the miner was not. This change supplies the missing field.

## Why Not `sha^`

Using `sha^` (parent of the head commit) is wrong for multi-commit PRs. It only steps back one commit on the PR branch, not to the base branch. The correct `base_sha` is `pr["base"]["sha"]` from the GitHub API — the commit on `main`/`master` that the PR branched from. For a 5-commit PR, `sha^` gives the diff of the last commit only; `base_sha` gives the diff of all 5 combined. The downstream `git diff base_sha commit_sha` in `_generate_solve_sh` and `_find_commit_test_files` depends on this being correct.

## Design

### 1. Data Model

**`Candidate` dataclass** — add `base_sha: str` (no default, required). Positioned alongside `sha`. Any code path that cannot supply a real `base_sha` fails at construction time.

### 2. `get_diff_stats`

Signature changes from single-SHA to two-SHA:

```python
# Before
def get_diff_stats(repo: Path, sha: str) -> dict:
    raw = git(repo, "diff-tree", "--no-commit-id", "-r", "--numstat", sha)

# After
def get_diff_stats(repo: Path, base_sha: str, sha: str) -> dict:
    raw = git(repo, "diff", "--numstat", base_sha, sha)
```

### 3. `get_prs`

New function. Pages through GitHub API for merged PRs via `gh` CLI:

```python
def get_prs(github_repo: str, after: str | None = None, max_count: int = 500) -> list[dict]:
    """Get merged PRs from GitHub API via gh CLI."""
```

- Uses `gh api repos/{github_repo}/pulls?state=closed&per_page=100&page={n}`
- Filters `merged_at != null`
- PRs are returned newest-first — once a full page is older than `after`, stops paging (breaks loop, does not continue to next page)
- Returns list of `{sha, base_sha, subject, author, date, pr_number}` where `sha` = `pr["merge_commit_sha"]` (the commit that lands on `main` after merge; guaranteed present in a local clone of the default branch regardless of squash vs regular merge). `pr["head"]["sha"]` is NOT used — feature branches may be deleted after merge.
- Stops paging when the first item on a page predates `after` (PRs are newest-first, so the first item older than `after` means all remaining items are also older)
- Raises `RuntimeError` on `gh` failure — no silent fallback

### 4. `analyze_pr`

New function, replaces `analyze_commit`. Takes PR dict (which already has `sha` and `base_sha`), calls `get_diff_stats(repo, pr["base_sha"], pr["sha"])`, builds `Candidate` with both SHAs. Scoring, classification, and clustering logic unchanged.

`analyze_commit` is removed entirely.

### 5. `mine_repo`

Adds `github_repo: str` parameter. Replaces:
```
get_commits() → analyze_commit()
```
with:
```
get_prs(github_repo) → analyze_pr()
```

The output JSON field `n_commits_scanned` is renamed to `n_prs_scanned`.

Clustering, scoring, sorting, and top-N slicing are unchanged.

### 6. `main()`

- **Batch mode (`--repos-csv`):** passes `entry["github_repo"]` to `mine_repo` — already present in CSV rows
- **Single-repo mode:** derives `github_repo` via `git remote get-url origin`, parses `owner/repo` from the URL, passes to `mine_repo`. Errors out if remote is not a GitHub URL.

No new CLI flags required.

### 7. Output format

Each candidate JSON gains `base_sha`. The `sha` field now holds `pr["merge_commit_sha"]` (was commit SHA, now merge commit SHA — same downstream semantics). The field `n_commits_scanned` is renamed `n_prs_scanned`. No other output fields change.

## No Commit Fallback

If GitHub API is unavailable (no auth, no network, non-GitHub remote), the miner errors out loudly. There is no fallback to commit-based walking. The sole purpose of this change is to get a real `base_sha` from GitHub — a fallback that produces wrong `base_sha` values defeats the point.

## Testing

Two known-good validation targets from existing pipeline runs:

Task ID formula: `repo.replace("-", "")[:2].upper() + sha[:4]`

| Task ID | Repo | Formula breakdown | How to verify |
|---|---|---|---|
| `e_celery_CEab71` | celery/celery | `CE` + `ab71` → `sha.startswith("ab71")` | check sha prefix |
| `e_networkx_8347` | networkx/networkx | `NE` + `sha[:4]` (unknown) | check `pr_number == 8347` in output |

**Test steps:**
1. Check out `feat/add-miner`, apply changes
2. Run miner on celery + networkx (both in `references/craft-repos.csv`)
3. Verify celery output has candidate with `sha.startswith("ab71")` and `base_sha` non-empty
4. Verify networkx output has candidate with `pr_number == 8347` and `base_sha` non-empty
5. Run `select_candidates` against the output — must pass without `KeyError` or `ValueError`
6. Spot-check: `git diff base_sha sha` on one candidate produces a non-empty patch
