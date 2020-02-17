class StocksController < ApplicationController
  def index
    @stocks = Stock.all
  end

  def show
    @stock = Stock.find(params[:id])
    #av = Alphavantage::Stock.new symbol: @stock.symbol, key: ENV['AV_KEY']
    #@avinfo = av.quote
  end

  def new
    @stock = Stock.new
    #stock = Alphavantage::Stock.new symbol: "QQQQQQQQQQQQ", key: ENV['AV_KEY']
    #stock_quote = stock.quote
    #puts stock_quote.symbol
    #puts stock_quote.open
  end

  def create
    @stock = Stock.new(stock_params)
    if @stock.save
      redirect_to @stock
    else
      render 'new'
    end

    #stock = Alphavantage::Stock.new symbol: :sym, key: ENV['AV_KEY']
    #stock_quote = stock.quote
    #puts stock_quote.symbol
    #puts stock_quote.open
  end

  private
  def stock_params
    params.require(:stock).permit(:symbol, :quantity)
  end
end