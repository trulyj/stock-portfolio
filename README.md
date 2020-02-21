# STOCK PORTFOLIO

This website can be found at: https://warm-wave-03980.herokuapp.com

This website uses the AlphaVantage API (with [StefanoMartin's gem](https://github.com/StefanoMartin/AlphaVantageRB)) and [Devise](https://github.com/heartcombo/devise) to let users make accounts and simulate buying and selling stocks from an initial balance of $5000. The "Manage" page contains a portfolio os the user's currently owned stocks as well as options to buy or sell stocks. The "Transactions" page contains the user's full transaction history.

Because of [limitations of the non-premium AlphaVantage API](https://www.alphavantage.co/premium/), API calls will fail when more than one is used in a minute. To prevent excessive API calls, the Manage page only updates the values of stocks if they haven't been updated in the last five minutes. To refresh a stock more frequently, go to its more info page and press "Refresh Stock Data".

AlphaVantage API requires an API key which you can get for free [here](https://www.alphavantage.co/support/#api-key). I used [dotenv](https://github.com/bkeepers/dotenv) to keep the API key secure in a .env file. You can see how this .env file can be structured so you can make your own by looking at .env.template.
