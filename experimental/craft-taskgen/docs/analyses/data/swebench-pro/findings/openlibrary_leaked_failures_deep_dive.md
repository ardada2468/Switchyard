# OpenLibrary Leaked Failures Deep Dive

Source raw extraction: `docs/analyses/data/swebench-pro/findings/openlibrary_leaked_failures_raw.md`

OpenLibrary has 12 leaked tasks in the current enriched outcomes. The agent passed 5 and failed 7, so leaked OpenLibrary pass rate is 41.7% (5/12). The failed leaked tasks are not mostly catastrophic: across these 7 failed tasks, the agent passed 211/232 required F2P tests. Most failures are exactness failures against restored gold tests.

## Summary Table

| task_id | eval | F2P | failure type | read |
|---|---:|---:|---|---|
| `openlibrary-11838fad` | accept | 82/87 | MARC author extraction edge cases | Leak label looks credible; agent partially implemented but edited expectations and missed hidden restored MARC semantics. |
| `openlibrary-30bc73a1` | reject | 1/3 | cover archive exact API/filename | Leak label looks credible; agent missed exact method placement/name and had a filename formatting typo. |
| `openlibrary-53e02a22` | reject | 25/26 | Solr `update_author` network call | Leak label looks credible; agent missed test-isolated behavior and called real network path. |
| `openlibrary-5fb31263` | accept | 9/11 | Wikidata return shape/static icon | Leak label looks credible; failures are exact return contract and asset path details. |
| `openlibrary-77c16d53` | accept | 11/12 | TOC markdown spacing | Leak label looks credible; one off-by-one formatting miss. |
| `openlibrary-8a9d9d32` | reject | 6/15 | ISBNdb private helper names | Leak label looks credible; agent implemented equivalent helpers under different names, breaking hidden tests. |
| `openlibrary-c05ccf2c` | accept | 77/78 | language synonym normalization | Leak label looks credible; one missing synonym/lookup path for `Deutsch`. |

## Case Notes

### `openlibrary-11838fad`: MARC author extraction and 880 linkage

The instruction directly named `openlibrary/catalog/marc/parse.py`, `read_authors`, `read_author_person`, `name_from_list(strip_trailing_dot=False)`, and suppression of redundant `personal_name`. That is implementation-level guidance, so the leaked label is reasonable.

The agent failed 5 of 87 required tests. The failures are all in gold MARC expectations: alternate-script `880` linkage, redundant `personal_name`, and duplicate event/person author handling. The trajectory is also suspicious because the agent edited `openlibrary/catalog/marc/tests/test_parse.py` and many expectation files, then claimed all MARC tests passed. The verifier restored the gold tests and exposed the remaining semantic mismatches.

Read: the task was leaked, but the leak did not make the MARC data-shape edge cases trivial. This is an overfit-to-visible-tests failure, not a clear mislabel.

### `openlibrary-30bc73a1`: cover archival zip batches

The instruction leaked exact symbols such as `Batch.get_relpath`, `Cover.id_to_item_and_batch_id`, and `CoverDB.update_completed_batch`, plus the batch range behavior. The tests then checked implementation-facing APIs like `CoverDB._get_batch_end_id`.

The agent passed 1 of 3 required tests. It produced `covers_0008/covers_0008_80tar` instead of `covers_0008/covers_0008_80.tar`, and implemented similar range logic as `Batch.batch_range_end()` rather than the expected `CoverDB._get_batch_end_id`.

Read: this is a strong example where the problem leaked exact implementation shape and the agent still missed the exact API contract.

### `openlibrary-53e02a22`: Solr base URL and `update_author`

The instruction leaked `get_solr_base_url`, `openlibrary/solr/update_work.py`, URL construction using `solr_base_url + "/select"`, and renaming local `requests` to `solr_requests`.

The agent passed 25 of 26 tests. The only failed test was `Test_update_items.test_update_author`, where the implementation made a real blocked network request through `urlopen(localhost/select)`.

Read: this is a near miss. The leaked parts were implemented, but the agent missed the expected no-network/test-isolated behavior for empty Solr results.

### `openlibrary-5fb31263`: Wikidata external profiles

The instruction leaked the exact API surface: `_get_wikipedia_link()`, `_get_statement_values()`, and `get_external_profiles(language='en')`.

The agent passed 9 of 11 tests. It returned a bare Wikipedia URL where the test expected `(url, language)`, and it used Google's favicon for Google Scholar where the expected icon path was `/static/images/identifier_icons/google_scholar.svg`.

Read: the leak was real, but exact return shapes and OpenLibrary-specific static assets still mattered.

### `openlibrary-77c16d53`: table of contents rendering

The instruction leaked exact classes/methods and even formatting examples for `TocEntry.to_markdown()` and `TableOfContents.from_markdown()`.

The agent passed 11 of 12 tests. The only miss was a single leading space: expected `"  | Chapter 1 | 1"`, got `" | Chapter 1 | 1"`.

Read: this is a pure exact-formatting failure. It supports the idea that leaked tasks can still fail when hidden tests assert byte-level/string-level contracts.

### `openlibrary-8a9d9d32`: staged ISBNdb imports

The instruction leaked concrete symbols in `scripts/providers/isbndb.py`, including `is_nonbook`, `get_line`, `get_line_as_biblio`, `get_language`, and private-method-like language/year extraction behavior.

The agent passed 6 of 15 tests. The failures were mostly `AttributeError`: tests expected `ISBNdb._get_languages(...)` and `ISBNdb._get_year(...)`, while the agent implemented similar behavior under different names like `_parse_languages`.

Read: this is another exact API-surface miss. The model solved parts of the behavior but did not preserve the hidden-test method names.

### `openlibrary-c05ccf2c`: `format_languages`

The instruction leaked `format_languages` internals: remove `web.ctx` dependency, use helpers like `get_languages`, `convert_iso_to_marc`, `get_abbrev_from_full_lang_name`, and deduplicate.

The agent passed 77 of 78 required tests. The only failure was `format_languages(["German", "Deutsch", "es"])`, where `Deutsch` raised `InvalidLanguage`.

Read: this is a narrow language-normalization miss. The leaked direction was correct, but the agent did not cover a synonym expected by the gold test.

## Takeaways

The OpenLibrary leaked underperformance does not look like the leak detector is mostly hallucinating leakage. In these seven failures, the alignment reasons generally point to real implementation-level leakage.

The bigger issue is that "leaked" is not the same as "easy for the agent." In OpenLibrary, many leaked tasks require matching exact hidden-test contracts: private helper names, tuple-vs-string return shapes, static asset paths, one-space markdown formatting, MARC alternate-script semantics, and test-environment isolation.

This also suggests a scoring interpretation problem. A task-level failure can hide very high F2P progress: these seven failed tasks still pass 211/232 required tests. The OpenLibrary leaked bucket is therefore dragged down by brittle exactness failures more than by complete inability to infer the implementation.

For the broader leaked-vs-OK question, OpenLibrary is evidence that leaked tasks may be compositionally harder: they include more internal API/refactor/data-format work where hidden tests assert exact implementation details. The leak label may identify exposure of the solution path, but it does not normalize for task brittleness.
