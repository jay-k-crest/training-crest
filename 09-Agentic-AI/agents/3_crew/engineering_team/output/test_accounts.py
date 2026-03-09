import unittest
import datetime
import accounts


class TestAccount(unittest.TestCase):
    def setUp(self):
        self.acct = accounts.Account("Tester")

    # ---------- Cash management ----------
    def test_deposit_positive(self):
        self.acct.deposit(1000.0)
        self.assertAlmostEqual(self.acct.get_cash(), 1000.0)
        self.assertAlmostEqual(self.acct._initial_deposit, 1000.0)

    def test_deposit_multiple(self):
        self.acct.deposit(500.0)
        self.acct.deposit(1500.0)
        self.assertAlmostEqual(self.acct.get_cash(), 2000.0)
        self.assertAlmostEqual(self.acct._initial_deposit, 2000.0)

    def test_deposit_invalid(self):
        with self.assertRaises(ValueError):
            self.acct.deposit(0)
        with self.assertRaises(ValueError):
            self.acct.deposit(-100)

    def test_withdraw_valid(self):
        self.acct.deposit(800.0)
        self.acct.withdraw(300.0)
        self.assertAlmostEqual(self.acct.get_cash(), 500.0)

    def test_withdraw_insufficient(self):
        self.acct.deposit(200.0)
        with self.assertRaises(ValueError):
            self.acct.withdraw(300.0)

    def test_withdraw_invalid(self):
        with self.assertRaises(ValueError):
            self.acct.withdraw(0)
        with self.assertRaises(ValueError):
            self.acct.withdraw(-50)

    # ---------- Share trading ----------
    def test_buy_valid(self):
        self.acct.deposit(5000.0)
        self.acct.buy("AAPL", 10)  # cost 1500
        self.assertAlmostEqual(self.acct.get_cash(), 3500.0)
        self.assertEqual(self.acct.get_holdings(), {"AAPL": 10})

    def test_buy_insufficient_cash(self):
        self.acct.deposit(1000.0)
        with self.assertRaises(ValueError):
            self.acct.buy("TSLA", 5)  # cost 1250

    def test_buy_invalid_quantity(self):
        self.acct.deposit(2000.0)
        with self.assertRaises(ValueError):
            self.acct.buy("AAPL", 0)
        with self.assertRaises(ValueError):
            self.acct.buy("AAPL", -3)

    def test_sell_valid(self):
        self.acct.deposit(2000.0)
        self.acct.buy("GOOGL", 10)  # cost 1200
        self.acct.sell("GOOGL", 4)  # revenue 480
        self.assertAlmostEqual(self.acct.get_cash(), 1280.0)
        self.assertEqual(self.acct.get_holdings(), {"GOOGL": 6})

    def test_sell_all_shares_removed(self):
        self.acct.deposit(2000.0)
        self.acct.buy("TSLA", 4)  # cost 1000
        self.acct.sell("TSLA", 4)  # should remove TSLA from holdings
        self.assertEqual(self.acct.get_holdings(), {})

    def test_sell_insufficient_shares(self):
        self.acct.deposit(1000.0)
        with self.assertRaises(ValueError):
            self.acct.sell("AAPL", 1)

    def test_sell_invalid_quantity(self):
        self.acct.deposit(1000.0)
        self.acct.buy("AAPL", 5)
        with self.assertRaises(ValueError):
            self.acct.sell("AAPL", 0)
        with self.assertRaises(ValueError):
            self.acct.sell("AAPL", -2)

    # ---------- Reporting ----------
    def test_portfolio_value_and_pnl(self):
        self.acct.deposit(5000.0)
        self.acct.buy("AAPL", 10)   # 1500
        self.acct.buy("TSLA", 10)   # 2500
        # cash remaining: 1000
        expected_value = 1000 + 10 * 150 + 10 * 250
        self.assertAlmostEqual(self.acct.portfolio_value(), expected_value)
        self.assertAlmostEqual(self.acct.profit_loss(), expected_value - 5000)

    def test_holdings_copy(self):
        self.acct.deposit(2000.0)
        self.acct.buy("AAPL", 5)
        holdings = self.acct.get_holdings()
        holdings["AAPL"] = 999  # modify copy
        # original should remain unchanged
        self.assertEqual(self.acct.get_holdings(), {"AAPL": 5})

    # ---------- Transactions ----------
    def test_transaction_records(self):
        self.acct.deposit(123.456)
        self.acct.withdraw(50.123)
        self.acct.deposit(200.0)
        self.acct.buy("AAPL", 2)
        self.acct.sell("AAPL", 1)

        txs = self.acct.transactions()
        self.assertEqual(len(txs), 5)

        # Check types and amounts
        # Deposit
        self.assertEqual(txs[0]["type"], "deposit")
        self.assertIsNone(txs[0]["symbol"])
        self.assertIsNone(txs[0]["quantity"])
        self.assertAlmostEqual(txs[0]["amount"], 123.46)
        self.assertIsInstance(txs[0]["timestamp"], datetime.datetime)

        # Withdraw
        self.assertEqual(txs[1]["type"], "withdraw")
        self.assertAlmostEqual(txs[1]["amount"], 50.12)

        # Second Deposit
        self.assertEqual(txs[2]["type"], "deposit")
        self.assertAlmostEqual(txs[2]["amount"], 200.0)

        # Buy
        self.assertEqual(txs[3]["type"], "buy")
        self.assertEqual(txs[3]["symbol"], "AAPL")
        self.assertEqual(txs[3]["quantity"], 2)
        self.assertAlmostEqual(txs[3]["amount"], 150.0)

        # Sell
        self.assertEqual(txs[4]["type"], "sell")
        self.assertEqual(txs[4]["symbol"], "AAPL")
        self.assertEqual(txs[4]["quantity"], 1)
        self.assertAlmostEqual(txs[4]["amount"], 150.0)

        # Ensure returned history is a shallow copy
        txs_copy = self.acct.transactions()
        txs_copy.append({"type": "fake"})
        self.assertEqual(len(self.acct.transactions()), 5)

    # ---------- _get_share_price ----------
    def test_get_share_price_known_symbols(self):
        self.assertAlmostEqual(accounts._get_share_price("AAPL"), 150.0)
        self.assertAlmostEqual(accounts._get_share_price("aapl"), 150.0)
        self.assertAlmostEqual(accounts._get_share_price("TSLA"), 250.0)
        self.assertAlmostEqual(accounts._get_share_price("googl"), 120.0)

    def test_get_share_price_unknown(self):
        with self.assertRaises(ValueError):
            accounts._get_share_price("MSFT")

    # ---------- Profit/Loss after withdrawals ----------
    def test_profit_loss_after_withdrawal(self):
        self.acct.deposit(1000.0)
        self.acct.withdraw(200.0)
        # portfolio value = cash = 800
        self.assertAlmostEqual(self.acct.profit_loss(), -200.0)

    # ---------- Edge case: sell to zero holdings ----------
    def test_sell_zero_holding_removal(self):
        self.acct.deposit(2000.0)
        self.acct.buy("TSLA", 4)
        self.acct.sell("TSLA", 4)
        self.assertEqual(self.acct.get_holdings(), {})


if __name__ == "__main__":
    unittest.main()
