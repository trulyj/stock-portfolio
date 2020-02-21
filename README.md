# STOCK PORTFOLIO

This website can be found at: https://warm-wave-03980.herokuapp.com

This website uses the IEX API (with [dblock's gem](https://github.com/dblock/iex-ruby-client)) and [Devise](https://github.com/heartcombo/devise) to let users make accounts and simulate buying and selling stocks from an initial balance of $5000. The "Manage" page contains a portfolio os the user's currently owned stocks as well as options to buy or sell stocks. The "Transactions" page contains the user's full transaction history.

IEX API requires an API key which you can get for free [here](https://iexcloud.io/cloud-login#/register). I used [dotenv](https://github.com/bkeepers/dotenv) to keep the API key secure in a .env file. You can see how this .env file can be structured so you can make your own by looking at .env.template.
