class StocksController < ApplicationController
  def new
    stock = Alphavantage::Stock.new symbol: "MSFT", key: ENV['AV_KEY']
    stock_quote = stock.quote
    puts stock_quote.symbol
    puts stock_quote.open
  end
end
