class StocksController < ApplicationController
  def new
    #stock = Alphavantage::Stock.new symbol: "MSFT", key: ENV['AV_KEY']
    #stock_quote = stock.quote
    #puts stock_quote.symbol
    #puts stock_quote.open
  end

  def create
    @stock = Stock.new(stock_params)
    @stock.save
    redirect_to @stock
    #stock = Alphavantage::Stock.new symbol: :sym, key: ENV['AV_KEY']
    #stock_quote = stock.quote
    #puts stock_quote.symbol
    #puts stock_quote.open
  end

  def show
    @stock = Stock.find(params[:id])
    av = Alphavantage::Stock.new symbol: @stock.symbol, key: ENV['AV_KEY']
    @avinfo = av.quote
  end

  private
  def stock_params
    params.require(:stock).permit(:symbol, :quantity)
  end
end
