require 'date'

class StocksController < ApplicationController
  def index
    redirect_to new_stock_path
    #@stocks = current_user.stocks
    #@stocks = Stock.all
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
    @user = current_user
    @stock = @user.stocks.new(stock_params)
    if @stock.save
      #stk = Alphavantage::Stock.new symbol: @stock.symbol, key: ENV['AV_KEY']
      #stk_quote = stk.quote
      #@user.balance = @user.balance - stk_quote.price*@stock.quantity
      @user.balance = @user.balance - 60
      @user.save
      @user.transactions.create(buyorsell: "BUY", symbol: @stock.symbol, quantity: @stock.quantity, price: 60, time: DateTime.now)
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
