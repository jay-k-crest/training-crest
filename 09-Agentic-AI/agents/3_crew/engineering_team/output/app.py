import gradio as gr
from accounts import Account
import json

# Create a single account instance for the demo
account = Account("Demo")

def _format_holdings(holdings):
    if not holdings:
        return "None"
    return "\n".join(f"{sym}: {qty}" for sym, qty in holdings.items())

def _format_history(history):
    if not history:
        return "No transactions yet."
    return "\n".join(
        f"{tx['timestamp']:%Y-%m-%d %H:%M:%S} | {tx['type'].upper():<8} | "
        f"{tx['symbol'] or '':<6} | {tx['quantity'] or '':>5} | ${tx['amount']:.2f}"
        for tx in history
    )

def update_status():
    return (
        f"Cash: ${account.get_cash():,.2f}",
        _format_holdings(account.get_holdings()),
        f"Portfolio Value: ${account.portfolio_value():,.2f}",
        f"Profit/Loss: ${account.profit_loss():,.2f}",
        _format_history(account.transactions()),
    )

def deposit(amount: float):
    try:
        account.deposit(float(amount))
        return f"Deposited ${amount:,.2f} successfully."
    except ValueError as e:
        return f"Error: {e}"

def withdraw(amount: float):
    try:
        account.withdraw(float(amount))
        return f"Withdrew ${amount:,.2f} successfully."
    except ValueError as e:
        return f"Error: {e}"

def buy(symbol: str, qty: int):
    try:
        account.buy(symbol.strip(), int(qty))
        return f"Bought {qty} shares of {symbol.upper()} successfully."
    except ValueError as e:
        return f"Error: {e}"

def sell(symbol: str, qty: int):
    try:
        account.sell(symbol.strip(), int(qty))
        return f"Sold {qty} shares of {symbol.upper()} successfully."
    except ValueError as e:
        return f"Error: {e}"

with gr.Blocks() as demo:
    gr.Markdown("## Trading Simulation Demo")
    with gr.Row():
        with gr.Column():
            gr.Markdown("### Cash Operations")
            amt_input = gr.Number(label="Amount ($)", precision=2)
            deposit_btn = gr.Button("Deposit")
            deposit_status = gr.Textbox(label="Deposit Status", lines=1, interactive=False)
            withdraw_btn = gr.Button("Withdraw")
            withdraw_status = gr.Textbox(label="Withdraw Status", lines=1, interactive=False)

            gr.Markdown("### Stock Operations")
            symbol_input = gr.Textbox(label="Symbol (e.g., AAPL)", placeholder="AAPL")
            qty_input = gr.Number(label="Quantity", precision=0)
            buy_btn = gr.Button("Buy Shares")
            buy_status = gr.Textbox(label="Buy Status", lines=1, interactive=False)
            sell_btn = gr.Button("Sell Shares")
            sell_status = gr.Textbox(label="Sell Status", lines=1, interactive=False)

        with gr.Column():
            gr.Markdown("### Account Summary")
            cash_output = gr.Textbox(label="Cash", interactive=False)
            holdings_output = gr.Textbox(label="Holdings", interactive=False)
            portfolio_output = gr.Textbox(label="Portfolio Value", interactive=False)
            pnl_output = gr.Textbox(label="Profit / Loss", interactive=False)
            history_output = gr.Textbox(label="Transaction History", lines=10, interactive=False)

    # Connect buttons to functions
    deposit_btn.click(
        fn=deposit,
        inputs=amt_input,
        outputs=deposit_status
    ).then(
        fn=update_status,
        inputs=[],
        outputs=[cash_output, holdings_output, portfolio_output, pnl_output, history_output]
    )

    withdraw_btn.click(
        fn=withdraw,
        inputs=amt_input,
        outputs=withdraw_status
    ).then(
        fn=update_status,
        inputs=[],
        outputs=[cash_output, holdings_output, portfolio_output, pnl_output, history_output]
    )

    buy_btn.click(
        fn=buy,
        inputs=[symbol_input, qty_input],
        outputs=buy_status
    ).then(
        fn=update_status,
        inputs=[],
        outputs=[cash_output, holdings_output, portfolio_output, pnl_output, history_output]
    )

    sell_btn.click(
        fn=sell,
        inputs=[symbol_input, qty_input],
        outputs=sell_status
    ).then(
        fn=update_status,
        inputs=[],
        outputs=[cash_output, holdings_output, portfolio_output, pnl_output, history_output]
    )

    # Initial load of status
    demo.load(fn=update_status, outputs=[cash_output, holdings_output, portfolio_output, pnl_output, history_output])

if __name__ == "__main__":
    demo.launch()