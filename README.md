# B-witch

A Clarity smart contract implementing a simple dead?man switch escrow for STX. Each owner registers a switch entry that names a beneficiary, heartbeat interval, and amount held by the contract. The owner can refresh the heartbeat; after the interval elapses, the beneficiary can be paid out.

## Storage
- `switch` map: keyed by owner principal, storing `{ beneficiary, last-heartbeat, interval, amount }`.

## Errors
- `ERR_INVALID_PARAMS` (`u400`) for invalid input values.
- `ERR_NOT_FOUND` (`u404`) when a switch entry is missing.
- `ERR_NOT_ELIGIBLE` (`u403`) when a claim is attempted before expiry.
- `ERR_ALREADY_EXISTS` (`u409`) when registering an existing entry.

## Public functions
- `register(beneficiary, interval, amount)`
  - Requires no existing entry for `tx-sender` and `interval > 0`, `amount > 0`.
  - Transfers `amount` STX from the sender into the contract, then records the entry with `last-heartbeat` set to the current `burn-block-height`.
- `heartbeat()`
  - Updates `last-heartbeat` for the caller?s entry.
- `claim(target)`
  - Requires the target?s interval to have elapsed.
  - Transfers the stored `amount` from the contract to the stored beneficiary and deletes the entry.
- `cancel()`
  - Refunds the stored `amount` back to the caller and deletes their entry.
