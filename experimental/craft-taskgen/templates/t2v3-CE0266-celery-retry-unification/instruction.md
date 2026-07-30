Solve the following task. Write your changes directly to the files in `/code/`.

Celery users report that `DatabaseBackend.store_result` creates far more database sessions than `result_backend_max_retries` would suggest under transient `DatabaseError` failures, leading to connection pool exhaustion. Separately, the group operations (`save_group`, `restore_group`, `delete_group`) and `forget` don't retry on transient errors at all — a single `DatabaseError` causes immediate failure.

Fix the `DatabaseBackend` so all its database operations retry consistently through the base `Backend`'s retry policy. `DatabaseBackend` should default to `always_retry=True` with `max_retries=3`, overridable via the standard `app.conf.result_backend_always_retry` and `app.conf.result_backend_max_retries` settings. On retry exhaustion, `store_result` raises `BackendStoreError`; other operations re-raise the original exception.
