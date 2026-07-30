# Zero-F2P Leaked Failures Deep Dive

## Scope

Among the 33 `leaked` tasks where the agent failed overall, 4 had zero verifier F2P tests pass:

| task_id | passed / total | failure shape |
|---|---:|---|
| `ansible-d72025be` | 0 / 5 | Rewrote core NXOS files and removed an expected test patch point |
| `ansible-1a4644ff` | 0 / 11 | Reintroduced code using `AUTH_KWARGS` after removing its import |
| `ansible-5640093f` | 0 / 4 | Mutated/overrode gather_facts config behavior and accessed missing redirect-list mocks |
| `ansible-c616e54a` | 0 / 6 | Changed `recursive_finder` signature, breaking existing callers |

Raw verifier excerpts are in `docs/analyses/data/swebench-pro/findings/zero_f2p_leaked_failures_raw.md`.

## `ansible-d72025be`: NXOS RMB State Fixes

Pipeline verdict:

- Eval verdict: `accept`
- Alignment verdict: `leaked`
- The leak reason is credible: the instruction names exact implementation entry points such as `default_intf_enabled`, `Interfaces.default_enabled`, `Interfaces.edit_config`, and exact NXOS fact commands.

Verifier result:

- 0 / 5 passed
- Every hidden unit test failed during `setUp`, before exercising the intended behavior.
- Error: `InterfacesFacts` no longer had `_device_info`.

What the agent did:

- Edited `interfaces.py` argspec and `nxos.py`.
- Completely rewrote `lib/ansible/module_utils/network/nxos/facts/interfaces/interfaces.py`.
- Completely rewrote `lib/ansible/module_utils/network/nxos/config/interfaces/interfaces.py`.
- Added local reproduction scripts.

Failure mode:

The agent over-implemented the leaked path by rewriting whole resource-module internals instead of making a smaller patch. The hidden tests expected the existing `InterfacesFacts._device_info` hook to still exist so they could patch it. The agent’s rewritten facts class dropped that method/attribute, so all five tests failed before reaching the actual RMB state assertions.

Interpretation:

This is leaked but not easy. The prompt exposed important implementation names, but the existing resource-module test harness still depended on old private structure. The agent broke compatibility with that harness while chasing the leaked design.

## `ansible-1a4644ff`: PSRP Extras Cleanup

Pipeline verdict:

- Eval verdict: `reject`
- Alignment verdict: `leaked`
- The leak reason is credible: the instruction explicitly names `_psrp_conn_kwargs`, `allow_extras`, and `AUTH_KWARGS`, and says `allow_extras` and `AUTH_KWARGS` references must be eliminated.

Verifier result:

- 0 / 11 passed
- Every parameterized `test_set_options` case failed.
- Error: `NameError: name 'AUTH_KWARGS' is not defined`.

What the agent did:

- Initially removed `AUTH_KWARGS` from the import and simplified `_psrp_conn_kwargs`.
- Then reverted part of that change: it restored the `AUTH_KWARGS`-driven unsupported-extras loop inside `_build_kwargs`.
- The final patch still referenced `AUTH_KWARGS`, but the runtime did not have a valid `AUTH_KWARGS` binding.

Failure mode:

This is a direct contradiction of the leaked instruction. The prompt said references to `AUTH_KWARGS` must be eliminated. The agent’s final state still used it, causing all tests to crash at `_build_kwargs()`.

Interpretation:

This is the clearest zero-pass case where the leak should have helped. The test looks fair: it is checking the exact private helper and internal kwargs structure named by the instruction. The agent failed because it ended with an inconsistent partial revert.

## `ansible-5640093f`: `module_defaults` Through Action Plugins

Pipeline verdict:

- Eval verdict: `accept`
- Alignment verdict: `leaked`
- The leak reason is credible: the instruction names exact functions and even the intended `module_loader.find_plugin_with_context(...)` logic for `gather_facts`, `package`, and `service`.

Verifier result:

- 0 / 4 passed
- Two failures showed `FACTS_MODULES` had been changed from `['smart']` to resolved modules like `['ansible.legacy.ios_facts']`.
- Two failures hit `AttributeError: Mock object has no attribute '_ansible_internal_redirect_list'`.

What the agent did:

- Added legacy-short-name handling in `get_action_args_with_defaults`.
- In `gather_facts._get_module_args`, used `self._task._ansible_internal_redirect_list` as a default redirect list, then tried to override it with `find_plugin_with_context(...)`.
- In `gather_facts.run`, copied `FACTS_MODULES`, expanded `smart` into a concrete facts module, and then wrote `task_vars['ansible_facts_modules'] = modules`.

Failure mode:

The agent got the high-level leaked path but mishandled two compatibility details:

- It assumed `_ansible_internal_redirect_list` exists on the task mock used by tests.
- It exposed the expanded facts module list back into config variables, so tests expecting `FACTS_MODULES == ['smart']` saw concrete module names instead.

Interpretation:

This is a leaked integration task where the prompt names the right APIs, but the surrounding behavior is delicate. The tests look fair: they check that the action plugin applies module defaults without mutating the externally visible `FACTS_MODULES` smart config and without relying on absent task internals.

## `ansible-c616e54a`: `module_common` Module Utils Finder

Pipeline verdict:

- Eval verdict: `reject`
- Alignment verdict: `leaked`
- The leak reason is credible: the instruction names exact internal classes like `ModuleUtilLocatorBase`, method `candidate_names_joined`, and says to replace recursion with a queue-based resolver.

Verifier result:

- 0 / 6 passed
- Every test failed immediately with:

```text
TypeError: recursive_finder() missing 2 required positional arguments: 'py_module_cache' and 'zf'
```

What the agent did:

- Added `ModuleDepFinder(is_pkg_init=...)`.
- Added locator classes.
- Replaced the old recursive finder with a queue-based implementation.

Failure mode:

The agent changed the public/internal call signature of `recursive_finder`. Existing unit tests and likely existing call sites still called:

```python
recursive_finder(name, module_fqn, data, *finder_containers)
```

The generated implementation expected additional positional arguments, so all tests failed before exercising the new resolver logic.

Interpretation:

This is another direct implementation-path leak, but the agent violated backward compatibility at the function boundary. The test is fair because preserving the existing `recursive_finder` callable contract is a basic expectation when refactoring internals.

## Cross-Case Pattern

These zero-pass cases are not evidence that the `leaked` label is mostly wrong. In all four, the prompt appears to leak meaningful internal implementation details.

The stronger pattern is:

1. The leak reveals where to work, but not necessarily how to preserve every existing private seam.
2. The agent often chased the leaked implementation path too aggressively.
3. Zero-pass usually came from an early crash or setup failure, not from subtly failing the target behavior:
   - missing `_device_info`
   - missing `AUTH_KWARGS`
   - missing `_ansible_internal_redirect_list`
   - changed `recursive_finder` signature

## Takeaway

For these four, "leaked" does not imply "the agent should trivially pass." It means the instruction exposed private code structure. The failures came from brittle compatibility requirements around existing internals and test harnesses. The most damning case for the agent is `ansible-1a4644ff`, where the leaked instruction explicitly said to remove `AUTH_KWARGS` references and the final patch still crashed on `AUTH_KWARGS`.
