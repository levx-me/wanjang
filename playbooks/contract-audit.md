# Contract Audit (Solidity / DeFi)

> Sources: agency-agents security-blockchain-security-auditor (MIT), paraphrased; [SWC Registry](https://swcregistry.io), [Solodit](https://solodit.cyfrin.io) (past findings), [OpenZeppelin Contracts docs](https://docs.openzeppelin.com/contracts) · Written 2026-10-27 · Applies to: Solidity on EVM chains, Foundry projects

**Use when:** the checker reviews a contract diff or a whole protocol for security, or a builder is about to ship one. Deployed contracts are immutable money; a missed bug cannot be hotfixed. For web/API code use `security-review.md`.

## Before you start
- Threat-model first, in writing, before reading line by line:
  - **Assets:** what can be lost (token balances, share price, collateral, fee accrual, governance power).
  - **Roles:** owner, admin, keeper, guardian, user, anyone. Who can call each state-changing function? (`forge inspect <C> methods`, or grep `external|public`.)
  - **Trust boundaries:** every external call, token, oracle, router, bridge, and upgrade target is untrusted unless proven otherwise.
  - **Invariants:** e.g. `sum(balances) == totalSupply`, `assets >= liabilities`, share price never decreases except by loss.
- Pin compiler and dependency versions and note the chain (L2 sequencer, reorgs). Read the whole call graph from each entry point, including inherited code and libraries (`forge flatten` or `forge inspect <C> storage-layout`).

## Rules (what to look for)

**1. Reentrancy**
- Any external call (token transfer with hooks, ETH send, callback) before state is final. Use checks-effects-interactions, plus `nonReentrant` as a second layer.
- Cross-function: function A calls out mid-update, attacker re-enters function B that reads the half-updated state.
- Read-only: a `view` used by another protocol (share price, `getReserves`) is read while the state is inconsistent. Guard views that others integrate, or lock the same flag.
```solidity
// Bad: interaction before effect
(bool ok,) = msg.sender.call{value: amt}(""); bal[msg.sender] -= amt;
// Good
bal[msg.sender] -= amt; (bool ok,) = msg.sender.call{value: amt}(""); require(ok);
```

**2. Access control and initialisers**
- Every state-changing function has an explicit modifier or a reason it needs none. Look for forgotten `onlyOwner` on setters, `mint`, `withdraw`, `sweep`, `setOracle`.
- `tx.origin` auth; `delegatecall` or arbitrary `call(target, data)` with user-supplied target or data; `selfdestruct` reachable.
- Initialisers: `initialize()` callable twice or by anyone on the implementation contract; implementation not locked with `_disableInitializers()` in the constructor; missing `onlyInitializing` in parent inits.

**3. Upgrades and storage**
- Proxy admin separated from user calls (selector clash); `upgradeTo` authorised.
- Compare storage layouts old vs new (`forge inspect Old storage-layout` vs `New`). New variables only appended; inherited-contract order unchanged; use gaps or ERC-7201 namespaced storage.

**4. Oracles and price manipulation**
- Spot price from a pool (`getReserves`, `slot0`) is manipulable within one transaction. Require TWAP over a window long enough for the pool's depth, or a robust oracle.
- Chainlink-style feeds: check `answer > 0`, `updatedAt` within the heartbeat, `answeredInRound`, decimals, and the L2 sequencer-uptime feed. On stale data revert or pause; never use 0.
- Price used for liquidation or minting must not be movable by the same actor in the same block.

**5. Flash-loan driven attacks**
- Ask of every balance-dependent computation: "what if the attacker briefly holds a huge amount?" Voting power from a current balance, share price from `balanceOf(this)`, reward per token from a spot pool, collateral valued at a manipulable price. Snapshots (past block) or same-block restrictions fix most.
- Donation: `balanceOf(address(this))` used as accounting can be inflated by direct transfer. Track internal accounting instead.

**6. Rounding, precision and share inflation**
- Division before multiplication; mixed decimals (6 vs 18); rounding direction must favour the protocol (round shares down on deposit, up on withdraw/burn of assets owed).
- ERC4626 first-depositor inflation: attacker deposits 1 wei, donates assets, later depositors round to 0 shares. Mitigate with virtual shares/assets offset (OpenZeppelin ERC4626 decimals offset), a dead-shares mint, or a minimum first deposit. Revert on zero shares/zero assets minted.

**7. Signatures, EIP-712, permit**
- Digest includes chain id, verifying contract, nonce, deadline; nonce consumed before use; no replay across chains or after a fork (domain separator recomputed if `chainid` changes).
- `ecrecover` returns `address(0)` on failure; reject it. Reject malleable `s` (use OpenZeppelin `ECDSA`). Contract signers need ERC-1271.
- `permit` front-run can grief a following `transferFrom` flow: wrap in try/catch and fall back to allowance.

**8. Front-running, MEV, slippage**
- Swaps, deposits and liquidations need `minOut` and `deadline` supplied by the caller, not `0` or `block.timestamp` computed inside the call. Public harvest/compound calls are sandwichable.

**9. Tokens: return values, fees, rebasing**
- Use `SafeERC20`; USDT-style tokens return nothing, some return `false`. `approve` race: use `forceApprove`.
- Fee-on-transfer: credit `balanceAfter - balanceBefore`, not `amount`. Rebasing/elastic supply tokens break stored balances. ERC777 hooks, blocklist tokens (USDC) can make a transfer revert and freeze a queue. Tokens with unusual decimals; tokens that pause.

**10. Denial of service**
- Loops over user-growable arrays; one failing recipient in a push-payment loop blocks all (use pull payments). Unbounded `delete`/array copy. Forced ETH via `selfdestruct` breaking `address(this).balance == x` checks.

**11. Time and block assumptions**
- `block.timestamp` is miner-adjustable by seconds; do not use it for randomness or for tight race windows. `block.number` is not time on L2s. Randomness from `blockhash`/`prevrandao` is not safe for value; use a VRF.

**12. Cross-chain and bridges**
- Message handler verifies the caller is the endpoint/router AND the source chain + source sender are allowlisted. Message ids are single-use (replay). Failed messages are retryable without loss. Decimals and token mapping match across chains. Finality/reorg assumptions stated.

**13. Admin keys and centralisation**
- List everything privileged roles can do: pause, upgrade, change fee, change oracle, mint, sweep tokens, blacklist. Which can steal user funds? A single EOA owner is a finding; expect multisig + timelock + bounded parameters (max fee, min delay). 

## Pitfalls
- "It uses OpenZeppelin / was audited." Integration glue is where bugs live.
- "Only the owner can call it." The owner key, a compromised keeper, or a proxy admin is part of the threat model.
- Reporting a pattern (e.g. "no reentrancy guard") with no path to loss. Build the path or downgrade it to informational.

## Verify (proving findings)
**A finding without a reproducing test is a suspicion, not a finding.** Write the exploit as a Foundry test that fails (attacker profits / invariant breaks) before the fix and passes after.
```solidity
function test_exploit_firstDepositorInflation() public {
    vm.startPrank(attacker); vault.deposit(1, attacker);
    asset.transfer(address(vault), 1e18);          // donation
    vm.stopPrank();
    vm.prank(victim); vault.deposit(1e18, victim);
    assertEq(vault.balanceOf(victim), 0);          // victim got zero shares
}
```
- **Fork tests** for anything touching live protocols: `forge test --fork-url $RPC --fork-block-number N` (pin the block so results are reproducible; never rely on latest).
- **Invariant tests** (`invariant_` functions with a handler contract bounding actions) for conservation of funds, solvency, share-price monotonicity. Fuzz amounts with `bound()`.
- **Tools** (leads only; local/fork chains only, never live): `slither .` , `forge inspect` (storage-layout, methods, abi), `forge coverage` to see untested branches, and `halmos` or `mythril` for symbolic checks if installed (say so if not). Run `forge build` and the full `forge test` first.

## Output format
List findings highest first; one block each:
```
[HIGH] src/Vault.sol:88  Share price inflatable by first depositor
Exploit: attacker deposits 1 wei, donates X, victim's deposit mints 0 shares; attacker redeems both.
Impact: victim loses their deposit (up to X).
Fix: virtual shares offset / revert on zero shares.
Test: test/audit/Inflation.t.sol::test_exploit_firstDepositorInflation (fails before fix, passes after)
```
Severity: CRITICAL (direct loss of user funds, no special privilege) · HIGH (loss under realistic conditions, or privileged theft) · MEDIUM (griefing, temporary lock, needs unusual conditions) · LOW (hardening, gas, best practice). Unproven items go in a separate "Suspicions" list. End with coverage: contracts read, contracts skipped, tools run and their results, assumptions (chain, token list, trusted roles), and what was not reviewed.
