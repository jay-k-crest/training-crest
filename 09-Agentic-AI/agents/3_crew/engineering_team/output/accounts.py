def _get_share_price(symbol: str) -> float:
    """
    Return a fixed test price for a given share symbol.
    Raises ValueError for unknown symbols.
    Prices:
        AAPL  150.0
        TSLA  250.0
        GOOGL 120.0
    """
    prices = {
        "AAPL": 150.0,
        "TSLA": 250.0,
        "GOOGL": 120.0,
    }
    try:
        return prices[symbol.upper()]
    except KeyError:
        raise ValueError(f"Unknown symbol '{symbol}'")


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

    def __init__(self, owner: str) -> None:
        """
        Create a new account for the given owner name.

        State initialised as:
            cash: float = 0.0
            holdings: dict[str, int] -> {}          # symbol -> quantity
            history: list[dict] -> []               # chronological transactions
            _initial_deposit: float = 0.0           # used for lifetime P&L
        """
        self.owner = owner
        self._cash: float = 0.0
        self._holdings: dict[str, int] = {}
        self._history: list[dict] = []
        self._initial_deposit: float = 0.0

    # ----------------------------------------------------------------------
    # Cash Management
    # ----------------------------------------------------------------------
    def deposit(self, amount: float) -> None:
        """
        Add cash to the account.
        amount must be > 0.
        Updates _initial_deposit on the very first deposit.
        """
        if amount <= 0:
            raise ValueError("Deposit amount must be positive")
        self._cash += amount
        if self._initial_deposit == 0.0:
            self._initial_deposit = amount
        else:
            self._initial_deposit += amount
        self._record_tx("deposit", None, None, amount)

    def withdraw(self, amount: float) -> None:
        """
        Remove cash if sufficient balance exists.
        amount must be > 0 and <= available cash.
        """
        if amount <= 0:
            raise ValueError("Withdraw amount must be positive")
        if not self._has_enough_cash(amount):
            raise ValueError("Insufficient cash for withdrawal")
        self._cash -= amount
        self._record_tx("withdraw", None, None, amount)

    # ----------------------------------------------------------------------
    # Share Trading
    # ----------------------------------------------------------------------
    def buy(self, symbol: str, quantity: int) -> None:
        """
        Purchase `quantity` shares of `symbol`.
        quantity must be a positive int.
        Total cost (quantity * current_price) must be <= cash on hand.
        Records transaction and updates holdings & cash.
        """
        if quantity <= 0:
            raise ValueError("Buy quantity must be a positive integer")
        price = _get_share_price(symbol)
        total_cost = price * quantity
        if not self._has_enough_cash(total_cost):
            raise ValueError("Insufficient cash to buy shares")
        self._cash -= total_cost
        sym = symbol.upper()
        self._holdings[sym] = self._holdings.get(sym, 0) + quantity
        self._record_tx("buy", sym, quantity, total_cost)

    def sell(self, symbol: str, quantity: int) -> None:
        """
        Sell `quantity` shares of `symbol`.
        quantity must be a positive int.
        User must hold at least `quantity` shares.
        Records transaction and updates holdings & cash.
        """
        if quantity <= 0:
            raise ValueError("Sell quantity must be a positive integer")
        sym = symbol.upper()
        if not self._has_enough_shares(sym, quantity):
            raise ValueError("Not enough shares to sell")
        price = _get_share_price(sym)
        revenue = price * quantity
        self._cash += revenue
        self._holdings[sym] -= quantity
        if self._holdings[sym] == 0:
            del self._holdings[sym]
        self._record_tx("sell", sym, quantity, revenue)

    # ----------------------------------------------------------------------
    # Reporting & Analytics
    # ----------------------------------------------------------------------
    def get_holdings(self) -> dict[str, int]:
        """Return a copy of the current share holdings mapping."""
        return self._holdings.copy()

    def get_cash(self) -> float:
        """Return current cash balance."""
        return self._cash

    def portfolio_value(self) -> float:
        """
        Return real-time market value of the account:
            cash + sum(holding_qty * current_price_per_share)
        """
        total = self._cash
        for symbol, qty in self._holdings.items():
            total += _get_share_price(symbol) * qty
        return total

    def profit_loss(self) -> float:
        """
        Return lifetime profit/loss versus the initial deposit:
            portfolio_value() - _initial_deposit
        """
        return self.portfolio_value() - self._initial_deposit

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
        # Return a shallow copy; dicts are immutable in this context.
        return self._history.copy()

    # ----------------------------------------------------------------------
    # Internal Helpers (private)
    # ----------------------------------------------------------------------
    def _record_tx(
        self,
        tx_type: str,
        symbol: str | None,
        quantity: int | None,
        amount: float,
    ) -> None:
        """
        Append a normalised transaction dict to history with current timestamp.
        """
        from datetime import datetime

        tx = {
            "type": tx_type,
            "symbol": symbol,
            "quantity": quantity,
            "amount": round(float(amount), 2),
            "timestamp": datetime.now(),
        }
        self._history.append(tx)

    def _has_enough_cash(self, required: float) -> bool:
        """Return True if cash >= required."""
        return self._cash >= required

    def _has_enough_shares(self, symbol: str, needed: int) -> bool:
        """Return True if holdings[symbol] >= needed."""
        return self._holdings.get(symbol.upper(), 0) >= needed


if __name__ == "__main__":
    # Minimal sanity checks
    acct = Account("Alice")
    print("Creating account for:", acct.owner)

    # Deposit
    acct.deposit(10000)
    print("Cash after deposit:", acct.get_cash())

    # Buy shares
    acct.buy("AAPL", 20)   # 20 * 150 = 3000
    acct.buy("TSLA", 10)   # 10 * 250 = 2500
    print("Cash after purchases:", acct.get_cash())
    print("Holdings:", acct.get_holdings())

    # Sell some shares
    acct.sell("AAPL", 5)   # 5 * 150 = 750
    print("Cash after selling AAPL:", acct.get_cash())
    print("Holdings after sell:", acct.get_holdings())

    # Withdraw
    acct.withdraw(2000)
    print("Cash after withdrawal:", acct.get_cash())

    # Portfolio and P&L
    print("Portfolio value:", acct.portfolio_value())
    print("Profit/Loss:", acct.profit_loss())

    # Transaction history
    for tx in acct.transactions():
        print(tx)