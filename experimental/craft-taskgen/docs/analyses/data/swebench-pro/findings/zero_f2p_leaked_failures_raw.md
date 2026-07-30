# Zero-F2P Leaked Failures Raw Summary

Count: 4

## ansible-d72025be (0/5)

- Repo: `ansible`
- Trial: `instance_ansible__ansible-d72025__hkj5ruN`
- Title: RMB state fixes
- SWE-bench id: `instance_ansible__ansible-d72025be751c894673ba85caa063d835a0ad3a8c-v390e508d27db7a51eece36bb6d9698b63a5b638a`
- Edited files: /app/lib/ansible/module_utils/network/nxos/argspec/interfaces/interfaces.py, /app/lib/ansible/module_utils/network/nxos/nxos.py, /app/lib/ansible/module_utils/network/nxos/facts/interfaces/interfaces.py, /app/lib/ansible/module_utils/network/nxos/config/interfaces/interfaces.py, /app/test_nxos_interfaces_fix.py, /app/test_nxos_interfaces_edge_cases.py

### Failed/Missing Tests

- `FAILED` `test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_1`
- `FAILED` `test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_2`
- `FAILED` `test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_3`
- `FAILED` `test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_4`
- `FAILED` `test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_5`

### Verifier Summary

```text
Running gold tests checkout: git checkout d72025be751c894673ba85caa063d835a0ad3a8c -- test/integration/targets/nxos_interfaces/tasks/main.yaml test/integration/targets/nxos_interfaces/tests/cli/deleted.yaml test/integration/targets/nxos_interfaces/tests/cli/merged.yaml test/integration/targets/nxos_interfaces/tests/cli/overridden.yaml test/integration/targets/nxos_interfaces/tests/cli/replaced.yaml test/units/modules/network/nxos/test_nxos_interfaces.py
Required tests: 5
Passed tests: 0
Required tests that passed: 0

RESULT: FAILED
Missing tests: ['test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_1', 'test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_4', 'test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_3', 'test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_5', 'test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_2']
```

### Failure Excerpt

```text
FAILED [ 20%]
test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_2 RERUN [ 40%]
test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_2 RERUN [ 40%]
test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_2 RERUN [ 40%]
test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_2 FAILED [ 40%]
test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_3 RERUN [ 60%]
test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_3 RERUN [ 60%]
test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_3 RERUN [ 60%]
test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_3 FAILED [ 60%]
test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_4 RERUN [ 80%]
test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_4 RERUN [ 80%]
test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_4 RERUN [ 80%]
test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_4 FAILED [ 80%]
test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_5 RERUN [100%]
test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_5 RERUN [100%]
test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_5 RERUN [100%]
test/units/modules/network/nxos/test_nxos_interfaces.py::TestNxosInterfacesModule::test_5 FAILED [100%]

=================================== FAILURES ===================================
_______________________ TestNxosInterfacesModule.test_1 ________________________
test/units/modules/network/nxos/test_nxos_interfaces.py:52: in setUp
    self._device_info = self.mock__device_info.start()
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
/usr/local/lib/python3.11/unittest/mock.py:1594: in start
    result = self.__enter__()
             ^^^^^^^^^^^^^^^^
/usr/local/lib/python3.11/unittest/mock.py:1446: in __enter__
    original, local = self.get_original()
                      ^^^^^^^^^^^^^^^^^^^
/usr/local/lib/python3.11/unittest/mock.py:1419: in get_original
    raise AttributeError(
E   AttributeError: <class 'ansible.module_utils.network.nxos.facts.interfaces.interfaces.InterfacesFacts'> does not have the attribute '_device_info'
_______________________ TestNxosInterfacesModule.test_2 ________________________
test/units/modules/network/nxos/test_nxos_interfaces.py:52: in setUp
    self._device_info = self.mock__device_info.start()
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
/usr/local/lib/python3.11/unittest/mock.py:1594: in start
    result = self.__enter__()
             ^^^^^^^^^^^^^^^^
/usr/local/lib/python3.11/unittest/mock.py:1446: in __enter__
    original, local = self.get_original()
                      ^^^^^^^^^^^^^^^^^^^
/usr/local/lib/python3.11/unittest/mock.py:1419: in get_original
    raise AttributeError(
E   AttributeError: <class 'ansible.module_utils.network.nxos.facts.interfaces.interfaces.InterfacesFacts'> does not have the attribute '_device_info'
_______________________ TestNxosInterfacesModule.test_3 ________________________
test/units/modules/network/nxos/test_nxos_interfaces.py:52: in setUp
    self._device_info = self.mock__device_info.start()
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
/usr/local/lib/python3.11/unittest/mock.py:1594: in start
    result = self.__enter__()
             ^^^^^^^^^^^^^^^^
/usr/local/lib/python3.11/unittest/mock.py:1446: in __enter__
    original, local = self.get_original()
                      ^^^^^^^^^^^^^^^^^^^
/usr/local/lib/python3.11/unittest/mock.py:1419: in get_original
    raise AttributeError(
E   AttributeError: <class 'ansible.module_utils.network.nxos.facts.interfaces.interfaces.InterfacesFacts'> does not have the attribute '_device_info'
_______________________ TestNxosInterfacesModule.test_4 ________________________
test/units/modules/network/nxos/test_nxos_interfaces.py:52: in setUp
    self._device_info = self.mock__device_info.start()
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
/usr/local/lib/python3.11/unittest/mock.py:1594: in start
    result = self.__enter__()
             ^^^^^^^^^^^^^^^^
/usr/local/lib/python3.11/unittest/mock.py:1446: in __enter__
    original, local = self.get_original()
                      ^^^^^^^^^^^^^^^^^^^
/usr/local/lib/python3.11/unittest/mock.py:1419: in get_original
    raise AttributeError(
E   AttributeError: <class 'ansible.module_utils.network.nxos.facts.interfaces.interfaces.InterfacesFacts'> does not have the attribute '_device_info'
_______________________ TestNxosInterfacesModule.test_5 ________________________
test/units/modules/network/nxos/test_nxos_interfaces.py:52: in setUp
    self._device_info = self.mock__dev
```

### Recent Bash Commands

- `python test_nxos_interfaces_fix.py`
- `python test_nxos_interfaces_fix.py`
- `python test_nxos_interfaces_edge_cases.py`
- `python test_nxos_interfaces_fix.py && echo "---" && python test_nxos_interfaces_edge_cases.py`
- `python -m pytest test/units/modules/network/nxos/test_nxos_interface.py -v --tb=short 2>&1 | tail -40`
- `python -m pytest test/units/modules/network/nxos/ -v --tb=short 2>&1 | tail -60`
- `rm /app/test_nxos_interfaces_fix.py /app/test_nxos_interfaces_edge_cases.py`

### Final Agent Message

```text
All changes are implemented and verified. Here's a summary of what was changed across the four files:

### Changes Summary

**1. `lib/ansible/module_utils/network/nxos/argspec/interfaces/interfaces.py`**
- Removed `'default': True` from the `enabled` parameter so it resolves dynamically instead of always assuming `True`.

**2. `lib/ansible/module_utils/network/nxos/nxos.py`**
- Added `default_intf_enabled(name, sysdefs, mode=None)` function that computes the correct default enabled/shutdown state based on interface type (loopback always True, ethernet/portchannel depends on mode), system defaults (L2_enabled, L3_enabled), and platform family.

**3. `lib/ansible/module_utils/network/nxos/facts/interfaces/interfaces.py`**
- Added `render_system_defaults(config)` method that parses `system default switchport` / `system default switchport shutdown` lines and platform family (N3K/N6K → L3_enabled=True) to produce `self.sysdefs`.
- Updated `populate_facts()` to query both system defaults and interface configs, detect platform type from capabilities, build `enabled_def` mapping and `default_interfaces` list, and store these as `interfaces_intf_defs` in facts.

**4. `lib/ansible/module_utils/network/nxos/config/interfaces/interfaces.py`**
- Added `edit_config(commands)` as a public wrapper around `self._connection.edit_config`.
- Added `default_enabled(want, have, action)` to determine the correct default admin state considering mode transitions and system defaults.
- Updated `get_interfaces_facts()` to store `intf_defs` from facts.
- Updated `set_config()` to augment the `have` list with default-only interfaces (preserving original facts for `result['before']`).
- Updated `_state_replaced()` to reset mode to system default when not specified in want.
- Updated `del_attribs()` to use system defaults for mode reset direction and compute enabled default based on the **target** mode (after reset), with a guard that returns empty when only the interface line would be generated.
- Updated `add_commands()` to put mode changes before other attributes.
```

## ansible-1a4644ff (0/11)

- Repo: `ansible`
- Trial: `instance_ansible__ansible-1a4644__8yWYMmb`
- Title: "## Title:\npsrp connection plugin accepts undocumented extras, causing ambiguous and inconsistent configuration.\n\n###
- SWE-bench id: `instance_ansible__ansible-1a4644ff15355fd696ac5b9d074a566a80fe7ca3-v30a923fb5c164d6cd18280c02422f75e611e8fb2`
- Edited files: /app/lib/ansible/plugins/connection/psrp.py

### Failed/Missing Tests

- `FAILED` `test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options2-expected2]`
- `FAILED` `test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options6-expected6]`
- `FAILED` `test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options8-expected8]`
- `FAILED` `test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options5-expected5]`
- `FAILED` `test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options1-expected1]`
- `FAILED` `test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options3-expected3]`
- `FAILED` `test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options10-expected10]`
- `FAILED` `test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options9-expected9]`
- `FAILED` `test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options0-expected0]`
- `FAILED` `test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options4-expected4]`
- `FAILED` `test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options7-expected7]`

### Verifier Summary

```text
Running gold tests checkout: git checkout 1a4644ff15355fd696ac5b9d074a566a80fe7ca3 -- test/units/plugins/connection/test_psrp.py
Required tests: 11
Passed tests: 0
Required tests that passed: 0

RESULT: FAILED
Missing tests: ['test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options4-expected4]', 'test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options5-expected5]', 'test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options0-expected0]', 'test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options1-expected1]', 'test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options9-expected9]', 'test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options10-expected10]', 'test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options6-expected6]', 'test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options3-expected3]', 'test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options7-expected7]', 'test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options8-expected8]', 'test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options2-expected2]']
```

### Failure Excerpt

```text
FAILED[0m test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options2-expected2] 
[gw6][36m [ 18%] [0m[31mFAILED[0m test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options6-expected6] 
[gw8][36m [ 27%] [0m[31mFAILED[0m test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options8-expected8] 
[gw5][36m [ 36%] [0m[31mFAILED[0m test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options5-expected5] 
[gw1][36m [ 45%] [0m[31mFAILED[0m test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options1-expected1] 
[gw3][36m [ 54%] [0m[31mFAILED[0m test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options3-expected3] 
[gw10][36m [ 63%] [0m[31mFAILED[0m test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options10-expected10] 
[gw9][36m [ 72%] [0m[31mFAILED[0m test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options9-expected9] 
[gw0][36m [ 81%] [0m[31mFAILED[0m test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options0-expected0] 
[gw4][36m [ 90%] [0m[31mFAILED[0m test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options4-expected4] 
[gw7][36m [100%] [0m[31mFAILED[0m test/units/plugins/connection/test_psrp.py::TestConnectionPSRP::test_set_options[options7-expected7] 

=================================== FAILURES ===================================
[31m[1m___________ TestConnectionPSRP.test_set_options[options2-expected2] ____________[0m
[gw2] linux -- Python 3.11.13 /usr/local/bin/python

self = <units.plugins.connection.test_psrp.TestConnectionPSRP object at 0x713292213950>
options = {'ansible_port': 1234}
expected = {'_psrp_conn_kwargs': {'ssl': True}, '_psrp_port': 1234}

    @pytest.mark.parametrize('options, expected',
                             ((o, e) for o, e in OPTIONS_DATA))
    def test_set_options(self, options, expected):
        pc = PlayContext()
        new_stdin = StringIO()
    
        conn = connection_loader.get('psrp', pc, new_stdin)
        conn.set_options(var_options=options)
>       conn._build_kwargs()

[1m[31mtest/units/plugins/connection/test_psrp.py[0m:200: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

self = <ansible.plugins.connection.psrp.Connection object at 0x7132922a7250>

    def _build_kwargs(self) -> None:
        self._psrp_host = self.get_option('remote_addr')
        self._psrp_user = self.get_option('remote_user')
        self._psrp_pass = self.get_option('remote_password')
    
        protocol = self.get_option('protocol')
        port = self.get_option('port')
        if protocol is None and port is None:
            protocol = 'https'
            port = 5986
        elif protocol is None:
            protocol = 'https' if int(port) != 5985 else 'http'
        elif port is None:
            port = 5986 if protocol == 'https' else 5985
    
        self._psrp_protocol = protocol
        self._psrp_port = int(port)
    
        self._psrp_path = self.get_option('path')
        self._psrp_auth = self.get_option('auth')
        # cert validation can either be a bool or a path to the cert
        cert_validation = self.get_option('cert_validation')
        cert_trust_path = self.get_option('ca_cert')
        if cert_validation == 'ignore':
            self._psrp_cert_validation = False
        elif cert_trust_path is not None:
            self._psrp_cert_validation = cert_trust_path
        else:
            self._psrp_cert_validation = True
    
        self._psrp_connection_timeout = self.get_option('connection_timeout')  # Can be None
        self._psrp_read_timeout = self.get_option('read_timeout')  # Can be None
        self._psrp_message_encryption = self.get_option('message_encryption')
        self._psrp_proxy = self.get_option('proxy')
        self._psrp_ignore_proxy = boolean(self.get_option('ignore_proxy'))
        self._psrp_operation_timeout = int(self.get_option('operation_timeout'))
        self._psrp_max_envelope_size = int(self.get_option('max_envelope_size'))
        self._psrp_configuration_name = self.get_option('configuration_name')
        self._psrp_reconnection_retries = int(self.get_option('reconnection_retries'))
        self._psrp_reconnection_backoff = float(self.get_option('reconnection_backoff'))
    
        self._psrp_certificate_key_pem = self.get_option('certificate_key_pem')
        self._psrp_certificate_pem = self.get_option('certificate_pem')
        self._psrp_credssp_auth_mechanism = self.get_option('credssp_auth_mechanism')
        self._psrp_credssp_disable_tlsv1_2 = self.get_option('credssp_disable_tlsv1_2')
        self._psrp_credssp_minimum_version = self.get_option('credssp_minimum_version')
        self._psrp_negotiate_send_cbt = self.get_option('negoti
```

### Recent Bash Commands

- `python -m pytest test/units/plugins/connection/test_psrp.py -v 2>&1 | tail -40`
- `git log --oneline -5 test/units/plugins/connection/test_psrp.py`
- `git show 718ce13673 --stat`
- `python -m pytest test/units/plugins/connection/test_psrp.py -v 2>&1`
- `python -m pytest test/units/plugins/connection/test_psrp.py -v 2>&1`
- `git diff lib/ansible/plugins/connection/psrp.py`

### Final Agent Message

```text
The change is clean and minimal. Here's what was done:

**Problem:** The `_psrp_conn_kwargs` dict conditionally included `read_timeout`, `reconnection_retries`, and `reconnection_backoff` based on `pypsrp.FEATURES` version checks. This meant playbooks behaved differently depending on the installed `pypsrp` version — sometimes silently falling back, sometimes warning.

**Fix:** Removed the two feature flag checks (`hasattr(pypsrp, 'FEATURES') and 'wsman_read_timeout' in pypsrp.FEATURES` and the corresponding `wsman_reconnections` check) and instead always include `read_timeout`, `reconnection_retries`, and `reconnection_backoff` directly in the `_psrp_conn_kwargs` dict alongside all other documented options. This ensures consistent, predictable behavior regardless of the underlying library version.
```

## ansible-5640093f (0/4)

- Repo: `ansible`
- Trial: `instance_ansible__ansible-564009__gh75WPw`
- Title: "## Title\n\n`module_defaults` of the underlying module are not applied when invoked via action plugins (`gather_facts`,
- SWE-bench id: `instance_ansible__ansible-5640093f1ca63fd6af231cc8a7fb7d40e1907b8c-vba6da65a0f3baefda7a058ebbd0a8dcafb8512f5`
- Edited files: /app/lib/ansible/executor/module_common.py, /app/lib/ansible/plugins/action/gather_facts.py, /app/lib/ansible/plugins/action/package.py, /app/lib/ansible/plugins/action/service.py

### Failed/Missing Tests

- `FAILED` `test/units/plugins/action/test_gather_facts.py::TestNetworkFacts::test_network_gather_facts_smart_facts_module_fqcn`
- `FAILED` `test/units/plugins/action/test_gather_facts.py::TestNetworkFacts::test_network_gather_facts_smart_facts_module`
- `FAILED` `test/units/plugins/action/test_gather_facts.py::TestNetworkFacts::test_network_gather_facts_fqcn`
- `FAILED` `test/units/plugins/action/test_gather_facts.py::TestNetworkFacts::test_network_gather_facts`

### Verifier Summary

```text
Running gold tests checkout: git checkout 5640093f1ca63fd6af231cc8a7fb7d40e1907b8c -- test/integration/targets/gathering_facts/runme.sh test/integration/targets/gathering_facts/test_module_defaults.yml test/integration/targets/package/tasks/main.yml test/integration/targets/service/tasks/tests.yml test/units/plugins/action/test_gather_facts.py
Required tests: 4
Passed tests: 0
Required tests that passed: 0

RESULT: FAILED
Missing tests: ['test/units/plugins/action/test_gather_facts.py::TestNetworkFacts::test_network_gather_facts_smart_facts_module_fqcn', 'test/units/plugins/action/test_gather_facts.py::TestNetworkFacts::test_network_gather_facts', 'test/units/plugins/action/test_gather_facts.py::TestNetworkFacts::test_network_gather_facts_smart_facts_module', 'test/units/plugins/action/test_gather_facts.py::TestNetworkFacts::test_network_gather_facts_fqcn']
```

### Failure Excerpt

```text
FAILED test/units/plugins/action/test_gather_facts.py::TestNetworkFacts::test_network_gather_facts_smart_facts_module_fqcn 
[gw2] [ 50%] FAILED test/units/plugins/action/test_gather_facts.py::TestNetworkFacts::test_network_gather_facts_smart_facts_module 
[gw1] [ 75%] FAILED test/units/plugins/action/test_gather_facts.py::TestNetworkFacts::test_network_gather_facts_fqcn 
[gw0] [100%] FAILED test/units/plugins/action/test_gather_facts.py::TestNetworkFacts::test_network_gather_facts 

=================================== FAILURES ===================================
______ TestNetworkFacts.test_network_gather_facts_smart_facts_module_fqcn ______
[gw3] linux -- Python 3.9.5 /usr/bin/python
self = <units.plugins.action.test_gather_facts.TestNetworkFacts testMethod=test_network_gather_facts_smart_facts_module_fqcn>
mock_collection_metadata = <MagicMock name='_get_collection_metadata' id='138354872392096'>

    @patch.object(module_common, '_get_collection_metadata', return_value={})
    def test_network_gather_facts_smart_facts_module_fqcn(self, mock_collection_metadata):
        self.fqcn_task_vars = {'ansible_network_os': 'cisco.ios.ios'}
        self.task.action = 'gather_facts'
        self.task.async_val = False
        self.task.args = {}
    
        plugin = GatherFactsAction(self.task, self.connection, self.play_context, loader=None, templar=self.templar, shared_loader_obj=None)
        get_module_args = MagicMock()
        plugin._get_module_args = get_module_args
        plugin._execute_module = MagicMock()
    
        res = plugin.run(task_vars=self.fqcn_task_vars)
    
        # assert the gather_facts config is 'smart'
        facts_modules = C.config.get_config_value('FACTS_MODULES', variables=self.fqcn_task_vars)
>       self.assertEqual(facts_modules, ['smart'])
E       AssertionError: Lists differ: ['cisco.ios.ios_facts'] != ['smart']
E       
E       First differing element 0:
E       'cisco.ios.ios_facts'
E       'smart'
E       
E       - ['cisco.ios.ios_facts']
E       + ['smart']

test/units/plugins/action/test_gather_facts.py:91: AssertionError
________ TestNetworkFacts.test_network_gather_facts_smart_facts_module _________
[gw2] linux -- Python 3.9.5 /usr/bin/python
self = <units.plugins.action.test_gather_facts.TestNetworkFacts testMethod=test_network_gather_facts_smart_facts_module>
mock_collection_metadata = <MagicMock name='_get_collection_metadata' id='134949853993328'>

    @patch.object(module_common, '_get_collection_metadata', return_value={})
    def test_network_gather_facts_smart_facts_module(self, mock_collection_metadata):
        self.fqcn_task_vars = {'ansible_network_os': 'ios'}
        self.task.action = 'gather_facts'
        self.task.async_val = False
        self.task.args = {}
    
        plugin = GatherFactsAction(self.task, self.connection, self.play_context, loader=None, templar=self.templar, shared_loader_obj=None)
        get_module_args = MagicMock()
        plugin._get_module_args = get_module_args
        plugin._execute_module = MagicMock()
    
        res = plugin.run(task_vars=self.fqcn_task_vars)
    
        # assert the gather_facts config is 'smart'
        facts_modules = C.config.get_config_value('FACTS_MODULES', variables=self.fqcn_task_vars)
>       self.assertEqual(facts_modules, ['smart'])
E       AssertionError: Lists differ: ['ansible.legacy.ios_facts'] != ['smart']
E       
E       First differing element 0:
E       'ansible.legacy.ios_facts'
E       'smart'
E       
E       - ['ansible.legacy.ios_facts']
E       + ['smart']

test/units/plugins/action/test_gather_facts.py:65: AssertionError
_______________ TestNetworkFacts.test_network_gather_facts_fqcn ________________
[gw1] linux -- Python 3.9.5 /usr/bin/python
self = <units.plugins.action.test_gather_facts.TestNetworkFacts testMethod=test_network_gather_facts_fqcn>
mock_collection_metadata = <MagicMock name='_get_collection_metadata' id='125388519627072'>

    @patch.object(module_common, '_get_collection_metadata', return_value={})
    def test_network_gather_facts_fqcn(self, mock_collection_metadata):
        self.fqcn_task_vars = {'ansible_network_os': 'cisco.ios.ios'}
        self.task.action = 'gather_facts'
        self.task.async_val = False
        self.task.args = {'gather_subset': 'min'}
        self.task.module_defaults = [{'cisco.ios.ios_facts': {'gather_subset': 'min'}}]
    
        plugin = GatherFactsAction(self.task, self.connection, self.play_context, loader=None, templar=self.templar, shared_loader_obj=plugin_loader)
        plugin._execute_module = MagicMock()
    
>       res = plugin.run(task_vars=self.fqcn_task_vars)

test/units/plugins/action/test_gather_facts.py:128: 
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
lib/ansible/plugins/action/gather_facts.py:95: in run
    mod_args = self._get_module_args(fact_module, task_vars)
lib/ansible/plugins/action/gather_facts.py:44: in _get_module_args
    redirect_list = self._task._ansib
```

### Recent Bash Commands

- `python -m pytest test/units/plugins/action/test_gather_facts.py -xvs 2>&1 | tail -60`
- `python -m pytest test/units/plugins/action/test_gather_facts.py::TestNetworkFacts::test_network_gather_facts_fqcn -xvs 2>&1 | tail -40`
- `python -m pytest test/units/plugins/action/test_gather_facts.py -xvs 2>&1 | tail -40`
- `python -m pytest test/units/plugins/action/ -xvs 2>&1 | tail -60`
- `python -m pytest test/units/executor/ -xvs 2>&1 | tail -40`
- `python3 -c "
import sys
sys.path.insert(0, '/app/lib')

from ansible.executor.module_common import get_action_args_with_defaults
from unittest.mock import MagicMock

templar = MagicMock()
templar.template = lambda x: x

# Test 1: ansible.legacy.setup should also match 'setup' in module_defaults
defa`
- `python3 -c "
import sys
sys.path.insert(0, '/app/lib')

from ansible import constants as C

# Verify that FACTS_MODULES config default is not mutated
val1 = C.config.get_config_value('FACTS_MODULES', variables={})
print('Before:', val1)
assert val1 == ['smart'], f'Expected [smart], got {val1}'

# Si`
- `python -m pytest test/units/plugins/action/test_gather_facts.py test/units/executor/ -v 2>&1 | tail -30`

### Final Agent Message

```text
All 77 tests pass. Here's a summary of the changes made across 4 files:

### 1. `lib/ansible/executor/module_common.py` — `get_action_args_with_defaults`
When iterating `redirected_names`, if a name starts with `ansible.legacy.`, also check the short name (without prefix) against `module_defaults`. This ensures defaults defined for `setup` are applied when the module is invoked as `ansible.legacy.setup`.

### 2. `lib/ansible/plugins/action/gather_facts.py`
- **`_get_module_args`**: Resolves the redirect list from the actual fact module via `module_loader.find_plugin_with_context()` instead of using the task's own redirect list. This ensures `module_defaults` for the underlying module (e.g., `cisco.ios.ios_facts`) are found.
- **`run`**: Uses `list()` to copy `FACTS_MODULES` config, preventing global config mutation that broke smart mode across multiple invocations. Stores the resolved modules in `task_vars['ansible_facts_modules']` so the config variable mechanism reflects the resolved value without mutating the global default.

### 3. `lib/ansible/plugins/action/package.py`
Resolves the redirect list from the actual package manager module (e.g., `dnf`, `apt`) via `module_loader.find_plugin_with_context()`, ensuring `module_defaults` for the underlying module are applied.

### 4. `lib/ansible/plugins/action/service.py`
Same pattern as package — resolves the redirect list from the actual service manager module (e.g., `systemd`, `sysvinit`) so its `module_defaults` are applied correctly.
```

## ansible-c616e54a (0/6)

- Repo: `ansible`
- Trial: `instance_ansible__ansible-c616e5__teND3GF`
- Title: "# Title\n\n`module_common` fails to resolve `module_utils` from collections (redirects, package `__init__` relative imp
- SWE-bench id: `instance_ansible__ansible-c616e54a6e23fa5616a1d56d243f69576164ef9b-v1055803c3a812189a1133297f7f5468579283f86`
- Edited files: /app/lib/ansible/executor/module_common.py

### Failed/Missing Tests

- `FAILED` `test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_no_module_utils`
- `FAILED` `test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_from_import_six`
- `FAILED` `test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_import_six_from_many_submodules`
- `FAILED` `test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_module_utils_with_identation_error`
- `FAILED` `test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_import_six`
- `FAILED` `test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_module_utils_with_syntax_error`

### Verifier Summary

```text
Running gold tests checkout: git checkout c616e54a6e23fa5616a1d56d243f69576164ef9b -- test/integration/targets/collections/collection_root_user/ansible_collections/testns/othercoll/plugins/module_utils/formerly_testcoll_pkg/__init__.py test/integration/targets/collections/collection_root_user/ansible_collections/testns/othercoll/plugins/module_utils/formerly_testcoll_pkg/submod.py test/integration/targets/collections/collection_root_user/ansible_collections/testns/testcoll/meta/runtime.yml test/integration/targets/collections/collection_root_user/ansible_collections/testns/testcoll/plugins/module_utils/nested_same/__init__.py test/integration/targets/collections/collection_root_user/ansible_collections/testns/testcoll/plugins/module_utils/nested_same/nested_same/__init__.py test/integration/targets/collections/collection_root_user/ansible_collections/testns/testcoll/plugins/module_utils/subpkg/__init__.py test/integration/targets/collections/collection_root_user/ansible_collections/testns/testcoll/plugins/module_utils/subpkg_with_init/__init__.py test/integration/targets/collections/collection_root_user/ansible_collections/testns/testcoll/plugins/module_utils/subpkg_with_init/mod_in_subpkg_with_init.py test/integration/targets/collections/collection_root_user/ansible_collections/testns/testcoll/plugins/modules/uses_collection_redirected_mu.py test/integration/targets/collections/collection_root_user/ansible_collections/testns/testcoll/plugins/modules/uses_leaf_mu_module_import_from.py test/integration/targets/collections/collection_root_user/ansible_collections/testns/testcoll/plugins/modules/uses_mu_missing.py test/integration/targets/collections/collection_root_user/ansible_collections/testns/testcoll/plugins/modules/uses_mu_missing_redirect_collection.py test/integration/targets/collections/collection_root_user/ansible_collections/testns/testcoll/plugins/modules/uses_mu_missing_redirect_module.py test/integration/targets/collections/collections/ansible_collections/testns/content_adj/plugins/module_utils/__init__.py test/integration/targets/collections/collections/ansible_collections/testns/content_adj/plugins/module_utils/sub1/__init__.py test/integration/targets/collections/posix.yml test/integration/targets/module_utils/module_utils_test.yml test/units/executor/module_common/test_recursive_finder.py
Required tests: 6
Passed tests: 0
Required tests that passed: 0

RESULT: FAILED
Missing tests: ['test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_from_import_six', 'test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_module_utils_with_syntax_error', 'test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_import_six_from_many_submodules', 'test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_import_six', 'test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_module_utils_with_identation_error', 'test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_no_module_utils']
```

### Failure Excerpt

```text
FAILED test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_no_module_utils 
[gw3] [ 33%] FAILED test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_from_import_six 
[gw5] [ 50%] FAILED test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_import_six_from_many_submodules 
[gw2] [ 66%] FAILED test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_module_utils_with_identation_error 
[gw4] [ 83%] FAILED test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_import_six 
[gw1] [100%] FAILED test/units/executor/module_common/test_recursive_finder.py::TestRecursiveFinder::test_module_utils_with_syntax_error 

=================================== FAILURES ===================================
___________________ TestRecursiveFinder.test_no_module_utils ___________________
[gw0] linux -- Python 3.9.23 /tmp/python-00u2zgmn-ansible/python
self = <test_recursive_finder.TestRecursiveFinder object at 0x7ca58ac1abe0>
finder_containers = FinderContainers(zf=<zipfile.ZipFile file=<_io.BytesIO object at 0x7ca58bb66db0> mode='w'>)

    def test_no_module_utils(self, finder_containers):
        name = 'ping'
        data = b'#!/usr/bin/python\nreturn \'{\"changed\": false}\''
>       recursive_finder(name, os.path.join(ANSIBLE_LIB, 'modules', 'system', 'ping.py'), data, *finder_containers)
E       TypeError: recursive_finder() missing 2 required positional arguments: 'py_module_cache' and 'zf'

test/units/executor/module_common/test_recursive_finder.py:91: TypeError
___________________ TestRecursiveFinder.test_from_import_six ___________________
[gw3] linux -- Python 3.9.23 /tmp/python-00u2zgmn-ansible/python
self = <test_recursive_finder.TestRecursiveFinder object at 0x7ab95b926c10>
finder_containers = FinderContainers(zf=<zipfile.ZipFile file=<_io.BytesIO object at 0x7ab9607a5950> mode='w'>)

    def test_from_import_six(self, finder_containers):
        name = 'ping'
        data = b'#!/usr/bin/python\nfrom ansible.module_utils import six'
>       recursive_finder(name, os.path.join(ANSIBLE_LIB, 'modules', 'system', 'ping.py'), data, *finder_containers)
E       TypeError: recursive_finder() missing 2 required positional arguments: 'py_module_cache' and 'zf'

test/units/executor/module_common/test_recursive_finder.py:114: TypeError
___________ TestRecursiveFinder.test_import_six_from_many_submodules ___________
[gw5] linux -- Python 3.9.23 /tmp/python-00u2zgmn-ansible/python
self = <test_recursive_finder.TestRecursiveFinder object at 0x7bb290a1ab80>
finder_containers = FinderContainers(zf=<zipfile.ZipFile file=<_io.BytesIO object at 0x7bb291cbb9a0> mode='w'>)

    def test_import_six_from_many_submodules(self, finder_containers):
        name = 'ping'
        data = b'#!/usr/bin/python\nfrom ansible.module_utils.six.moves.urllib.parse import urlparse'
>       recursive_finder(name, os.path.join(ANSIBLE_LIB, 'modules', 'system', 'ping.py'), data, *finder_containers)
E       TypeError: recursive_finder() missing 2 required positional arguments: 'py_module_cache' and 'zf'

test/units/executor/module_common/test_recursive_finder.py:126: TypeError
_________ TestRecursiveFinder.test_module_utils_with_identation_error __________
[gw2] linux -- Python 3.9.23 /tmp/python-00u2zgmn-ansible/python
self = <test_recursive_finder.TestRecursiveFinder object at 0x7049000e6c10>
finder_containers = FinderContainers(zf=<zipfile.ZipFile file=<_io.BytesIO object at 0x7049009e5810> mode='w'>)

    def test_module_utils_with_identation_error(self, finder_containers):
        name = 'fake_module'
        data = b'#!/usr/bin/python\n    def something():\n    pass\n'
        with pytest.raises(ansible.errors.AnsibleError) as exec_info:
>           recursive_finder(name, os.path.join(ANSIBLE_LIB, 'modules', 'system', 'fake_module.py'), data, *finder_containers)
E           TypeError: recursive_finder() missing 2 required positional arguments: 'py_module_cache' and 'zf'

test/units/executor/module_common/test_recursive_finder.py:105: TypeError
_____________________ TestRecursiveFinder.test_import_six ______________________
[gw4] linux -- Python 3.9.23 /tmp/python-00u2zgmn-ansible/python
self = <test_recursive_finder.TestRecursiveFinder object at 0x765145526c10>
finder_containers = FinderContainers(zf=<zipfile.ZipFile file=<_io.BytesIO object at 0x76514639a9f0> mode='w'>)

    def test_import_six(self, finder_containers):
        name = 'ping'
        data = b'#!/usr/bin/python\nimport ansible.module_utils.six'
>       recursive_finder(name, os.path.join(ANSIBLE_LIB, 'modules', 'system', 'ping.py'), data, *finder_containers)
E       TypeError: recursive_finder() missing 2 required positional arguments: 'py_module_cache' and 'zf'

test/units/executor/module_common/test_recursive_finder.py:120: TypeError
___________ TestRecursiveFinder.test_module_utils_with_syntax_error ____________
[gw1] linux -- Py
```

### Recent Bash Commands

- `python -m pytest test/units/executor/module_common/ -v 2>&1 | tail -30`
- `python -m pytest test/units/executor/module_common/test_recursive_finder.py -v 2>&1`
- `python -m pytest test/units/executor/module_common/ -v 2>&1`
- `python -c "
from ansible.executor.module_common import (
    ModuleUtilLocatorBase, LegacyModuleUtilLocator, CollectionModuleUtilLocator,
    ModuleDepFinder, recursive_finder
)

# 1. Verify classes exist and have right interfaces
base = ModuleUtilLocatorBase(('ansible', 'module_utils', 'basic'))
as`
- `python -c "
import ast
from ansible.executor.module_common import ModuleDepFinder

# Test six normalization
code = 'from ansible.module_utils.six.moves.urllib.parse import urlparse'
tree = compile(code, '<test>', 'exec', ast.PyCF_ONLY_AST)
finder = ModuleDepFinder('test_module')
finder.visit(tree)
p`
- `python -c "
import ast
from ansible.executor.module_common import ModuleDepFinder

# from ..cousin import Y in a __init__.py of mypkg
code = 'from ..cousin import Y'
tree = compile(code, '<test>', 'exec', ast.PyCF_ONLY_AST)

# In __init__.py: level 2 becomes level 1 after adjustment
finder_init = Mo`
- `python -m pytest test/units/executor/module_common/ -v 2>&1`
- `python -m pytest test/units/executor/module_common/ -v 2>&1`

### Final Agent Message

```text
All 47 tests pass. Here's a summary of what was changed in `lib/ansible/executor/module_common.py`:

**1. `ModuleDepFinder`** — Added `is_pkg_init` parameter. When processing an `__init__.py` file, the relative import level is decremented by 1 so that `from .submod import X` resolves relative to the package itself (not its parent).

**2. `ModuleUtilLocatorBase`** — New base class tracking `found`, `redirected`, `source`, `output_path`, `is_package`, and `fq_name_parts`. Provides `candidate_names_joined()` returning dot-joined candidate names.

**3. `LegacyModuleUtilLocator`** — For `ansible.module_utils.*`. Tries local resolution first via `ModuleInfo`, then falls back to `InternalRedirectModuleInfo` for redirect shims. Ambiguity (module vs attribute) only applies when more than one level below `module_utils`.

**4. `CollectionModuleUtilLocator`** — For `ansible_collections.*`. Checks collection metadata redirect-first (including tombstone/deprecation handling), then falls back to `CollectionModuleInfo` for local resolution. FQCN redirects are expanded to full `ansible_collections.ns.coll.plugins.module_utils.mod` paths. Missing collections produce `"unable to locate collection"` errors.

**5. `recursive_finder`** — Replaced recursive implementation with a queue-based loop. Each iteration parses imports, resolves them through the appropriate locator, synthesizes empty `__init__.py` files for missing packages, writes to zip, and queues newly discovered modules for scanning. Error messages follow the format: `"Could not find imported module support code for {name}. Looked for ({candidates})"`.
```
