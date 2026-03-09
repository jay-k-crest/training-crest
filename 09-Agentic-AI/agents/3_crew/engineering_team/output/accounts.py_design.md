```markdown
# Module: accounts.py

## Purpose
Self-contained simulation of a single brokerage account.  
One public class, `Account`, exposes all required behaviour.  
A private helper `_get_share_price` is supplied with fixed test prices.

---

## External Helper (kept private to the module)

```python
def _get_share_price(symbol: str) -> float:
    """
    Return a fixed test price for a given share symbol.
    Raises ValueError for unknown symbols.
    Prices:
        AAPL  150.0
        TSLA  250.0
        GOOGL 120.0
    """
```

---

## Public Class

```python
class Account:
    """
    A simple trading-simulation account.

    Users can:
      - deposit / withdraw cash
      - buy / sell shares by symbol & quantity
      - inspect holdings, cash, portfolio value, P&L
      - list transaction history

    All business-rule enforcement (insufficient funds, short-selling, etc.)
    is handled internally; invalid operations raise ValueError with
    descriptive messages.
    """
```

---

## Constructor

```python
def __init__(self, owner: str) -> None:
    """
    Create a new account for the given owner name.

    State initialised as:
        cash: float = 0.0
        holdings: dict[str, int] -> {}          # symbol -> quantity
        history: list[dict] -> []             # chronological transactions
        _initial_deposit: float = 0.0          # used for lifetime P&L
    """
```

---

## Cash Management

```python
def deposit(self, amount: float) -> None:
    """
    Add cash to the account.
    amount must be > 0.
    Updates _initial_deposit on the very first deposit.
    """

def withdraw(self, amount: float) -> None:
    """
    Remove cash if sufficient balance exists.
    amount must be > 0 and <= available cash.
    """
```

---

## Share Trading

```python
def buy(self, symbol: str, quantity: int) -> None:
    """
    Purchase `quantity` shares of `symbol`.
    quantity must be a positive int.
    Total cost (quantity * current_price) must be <= cash on hand.
    Records transaction and updates holdings & cash.
    """

def sell(self, symbol: str, quantity: int) -> None:
    """
    Sell `quantity` shares of `symbol`.
    quantity must be a positive int.
    User must hold at least `quantity` shares.
    Records transaction and updates holdings & cash.
    """
```

---

## Reporting & Analytics

```python
def get_holdings(self) -> dict[str, int]:
    """Return a copy of the current share holdings mapping."""

def get_cash(self) -> float:
    """Return current cash balance."""

def portfolio_value(self) -> float:
    """
    Return real-time market value of the account:
        cash + sum(holding_qty * current_price_per_share)
    """

def profit_loss(self) -> float:
    """
    Return lifetime profit/loss versus the initial deposit:
        portfolio_value() - _initial_deposit
    """

def transactions(self) -> list[dict]:
    """
    Return a chronological list of all transactions.
    Each dict contains:
        type: str       ('deposit', 'withdraw', 'buy', 'sell')
        symbol: str|None
        quantity: int|None
        amount: float   (cash involved, always positive)
        timestamp: datetime
    """
```

---

## Internal Helpers (private)

```python
def _record_tx(self, tx_type: str, symbol: str | None,
               quantity: int | None, amount: float) -> None:
    """
    Append a normalised transaction dict to history with current timestamp.
    """

def _has_enough_cash(self, required: float) -> bool:
    """Return True if cash >= required."""

def _has_enough_shares(self, symbol: str, needed: int) -> bool:
    """Return True if holdings[symbol] >= needed."""
```

---

## Exceptions Raised
All public methods validate inputs and business rules; failures raise `ValueError` with clear messages (e.g. "Insufficient cash", "Short sale not allowed").

---

## Module Self-Test (only executed when run as script)

```python
if __name__ == "__main__":
    # Minimal sanity checks to ensure class loads and basic flows work.
    ...
```

The file is ready for unit-test or lightweight UI integration without any external dependencies beyond Python stdlib.
```