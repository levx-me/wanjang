# Solidity contracts with Foundry

> Sources: agency-agents engineering-solidity-smart-contract-engineer (MIT), paraphrased; [Foundry Book](https://book.getfoundry.sh); flags checked against `forge` 1.8.3 `--help` · Written 2026-10-27 · Applies to: Solidity 0.8.x with Foundry (forge, cast, anvil)

**Use when:** writing, testing, deploying or upgrading Solidity contracts in a Foundry project. Contract code is hard to patch once live and moves real money, so tests, dry runs and explicit approval come before every on-chain write.

## Before you start
- Read `foundry.toml`, `remappings.txt`, existing tests and scripts; match their pragma and naming.
- Run `forge build` first for a baseline of existing warnings.
- Find out which chains and addresses are in play. Read RPC URLs and keys from the environment or a keystore, and never choose a target on your own (see rule 21).
- If a deployed instance exists, every change is an upgrade (rules 14-17).

## Rules

### Layout and config
1. Keep `src/` for contracts, `test/` for tests (`Name.t.sol`), `script/` for deploy scripts (`Name.s.sol`), `lib/` for git-installed dependencies.
2. Pin the compiler in `foundry.toml` (`solc = "0.8.28"`, never a floating range) plus `optimizer = true`, `optimizer_runs`, and `evm_version` matching the target chain. Commit `foundry.lock` or pin deps by commit (`forge install org/repo@<tag>`).
3. Use profiles for the settings that differ, and select them with `FOUNDRY_PROFILE=ci`:
```toml
[profile.default]
solc = "0.8.28"
optimizer = true
optimizer_runs = 200
fuzz = { runs = 256 }
invariant = { runs = 64, depth = 64 }

[profile.ci]
fuzz = { runs = 5000 }

[rpc_endpoints]
mainnet = "${MAINNET_RPC_URL}"   # env reference, never a literal key
```
4. Put import aliases in `remappings.txt` (`@openzeppelin/=lib/openzeppelin-contracts/`) and import by alias, not by `../../lib/...`.

### Build and test commands
5. Know the flags (checked against `--help`):
```sh
forge build --sizes                         # contract size report; 24576-byte limit
forge test                                  # whole suite
forge test --match-contract Vault -vvv      # by contract; --match-test <regex>, --match-path <glob>
forge test -vvvv --match-test test_withdraw # full traces for the failing test
forge test --rerun                          # only tests that failed last run
forge test --gas-report                     # per-function gas table
forge snapshot --diff                       # compare gas to .gas-snapshot; --check fails on any change
forge fmt --check && forge lint             # format and lint
```

### Tests
6. Unit tests: one behaviour per test, named `test_Action_Condition` and `test_RevertWhen_Condition`. Use `vm.expectRevert(Errors.NotOwner.selector)` just before the call, and `vm.expectEmit` before the call plus the expected event after it.
7. Cover success, every revert, boundaries (0, 1, max) and each role (owner, stranger, zero address).
8. Fuzz tests: take parameters in `test_Fuzz_...(uint256 amount)` and bound them with `bound(amount, 1, MAX)` instead of `vm.assume`. Assert a property, not a copy of the implementation.
9. Invariant tests: write a handler contract that wraps the system, bounds its inputs, uses a small fixed set of actors, and is the only target (`targetContract(address(handler))`). Track expected totals in ghost variables on the handler (`ghostDeposited`) and assert them against real state in `invariant_*` functions (solvency, `totalSupply == sum(balances)`, no user over-withdraws).
10. Fork tests: use for integrations with live protocols only. Pin the block (`--fork-url $MAINNET_RPC_URL --fork-block-number 21000000`, or `vm.createSelectFork("mainnet", 21000000)`) so runs are reproducible and cached. Use a read-only RPC key, never a key that can spend.

### Contract design
11. Order every state-changing function: checks, effects, interactions. Update storage before any external call; add `nonReentrant` on functions that move value or call untrusted code, as a second layer, not a replacement.
12. Use custom errors (`error InsufficientBalance(uint256 have, uint256 need);`) instead of revert strings, and emit an event for every state change an off-chain reader needs, with `indexed` on the fields they filter by.
13. Access control: use `Ownable2Step` or `AccessControl` from the audited library. Every external setter, mint, pause and upgrade function gets an explicit modifier. A function with no modifier is deliberate, and a comment says why.

### Upgradeable contracts
14. Choose UUPS or Transparent proxy once, using the OpenZeppelin upgradeable contracts. With UUPS the implementation holds `_authorizeUpgrade(address) onlyOwner`; leaving it empty or unprotected lets anyone upgrade.
15. Implementations have no constructor logic. Call `_disableInitializers()` in the constructor, and set state in an `initialize(...)` marked `initializer` (or `reinitializer(n)` for later versions). Call each parent's `__X_init`.
16. Storage is append-only: never reorder, retype or remove variables; add new ones at the end and reduce the `uint256[50] __gap` by the same slots (or use ERC-7201 namespaced storage).
17. Before any upgrade, diff the layouts of the deployed and the new implementation, and stop on any change that is not append-only:
```sh
forge inspect src/VaultV1.sol:VaultV1 storageLayout --json > /tmp/v1.json
forge inspect src/VaultV2.sol:VaultV2 storageLayout --json > /tmp/v2.json
diff <(jq '.storage[]|{label,slot,offset,type}' /tmp/v1.json) <(jq '.storage[]|{label,slot,offset,type}' /tmp/v2.json)
```
Also test: deploy V1 behind a proxy, write state, upgrade to V2, read the state back.

### ERC20 and gas
18. Use `SafeERC20` (`safeTransfer`, `safeTransferFrom`, `forceApprove`) for every token call; tokens like USDT return nothing, and some revert on non-zero to non-zero approvals. Credit the balance difference for fee-on-transfer tokens; never assume 18 decimals.
19. Gas habits that keep safety: pack storage slots, use `immutable` and `constant`, cache storage reads in a local variable, `calldata` for read-only external arrays, `unchecked` only where an invariant visibly rules out overflow (comment the invariant). Never drop access checks, zero-address checks or reentrancy guards for gas.

### Static analysis
20. Before calling work done, run `forge build` with no new warnings, `forge fmt --check`, `forge lint`, and `slither .` if installed. Triage every finding: fix it, or suppress it with a one-line reason.

### Deployment
21. Scripts inherit `Script`, wrap on-chain calls in `vm.startBroadcast()` / `vm.stopBroadcast()`, read config from env (`vm.envAddress`), and write nothing to a chain you were not told to use. Without `--broadcast`, `forge script` only simulates, so always run that first:
```sh
forge script script/Deploy.s.sol --rpc-url $RPC_URL                 # dry run, no transaction sent
forge script script/Deploy.s.sol --rpc-url $RPC_URL --account deployer --sender $DEPLOYER \
  --broadcast --verify                                              # only after explicit approval
```
Rehearse on anvil, then a testnet, before mainnet.
22. `--broadcast` needs the user's explicit approval for that chain and that script, in the current conversation. Show the dry-run output (chain id, sender, calls) when asking. `--resume` continues an interrupted broadcast; do not re-run a broadcast hoping it is idempotent.
23. Keys: use `--account` (encrypted keystore from `cast wallet import`) or a hardware wallet. Never pass `--private-key` on the command line, never commit `.env`, never print a key. Confirm `.env` is ignored with `git check-ignore -v .env`.
24. After deploy, verify on the explorer (`--verify` with `ETHERSCAN_API_KEY`, or `forge verify-contract`), read key state back with `cast call` (owner, implementation, initialized).

## Pitfalls
- **`vm.assume` on narrow ranges** starves the fuzzer; use `bound`.
- **Invariants that pass because the handler reverts** every call; check call counts.
- **Upgrade without a layout diff**: silent storage corruption.
- **`--broadcast` pasted from an earlier command** against another `$RPC_URL`.

## Verify
- `forge build --sizes` has no contract over the limit; `forge test` passes with the `ci` profile (`FOUNDRY_PROFILE=ci forge test`).
- `forge fmt --check`, `forge lint`, and `slither .` show no unexplained findings; `forge snapshot --diff` shows only expected gas changes.
- For an upgrade: layout diff is append-only and the V1-to-V2 state test passes.
- The deploy dry run was read, the chain id and sender match the intent, and the user approved the broadcast before it ran. Addresses and ownership were checked after with `cast call`.

## Contract
No transaction is sent without explicit approval for that chain and script, after a dry run. Every external state change has access control, an event and a revert test. Every upgrade has a layout diff and a state-preservation test. Every ERC20 call goes through SafeERC20.
