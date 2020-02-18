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
    #@totalval = (@avinfo.price).to_f * (@stock.quantity)
    @totalval = (@stock.share_price) * (@stock.quantity)
    #puts @avinfo.price
    puts @stock.quantity
    puts @totalval
  end

  def new
    @stock = Stock.new
    #stock = Alphavantage::Stock.new symbol: "QQQQQQQQQQQQ", key: ENV['AV_KEY']
    #stock_quote = stock.quote
    #puts stock_quote.symbol
    #puts stock_quote.open
  end

  def create
    puts "Enter create"
    @user = current_user
    @stock = @user.stocks.new(stock_params)
    begin
      puts "BEGIN"
      stk = Alphavantage::Stock.new symbol: params[:stock][:symbol], key: ENV['AV_KEY']
      puts "API CALL DONE"
      puts stk.inspect
      stock_quote = stk.quote
      puts "QUOTE EXTRACTED"
      av_price = (stock_quote.price).to_f
      av_open = (stock_quote.open).to_f
      puts "PRICE CONVERTED"
      puts av_price
      #p = 60
      if av_price*@stock.quantity > @stock.user.balance
        @stock.errors[:base] << "You do not have enough money to make this transaction."
      end
    rescue Alphavantage::Error => e
      @stock.errors[:base] << "API call failed. Stock symbol is invalid or there may have been too many API calls. Try again in 5 minutes!"
    end
    #@stock = @user.stocks.new(stock_params)
    #stk = Alphavantage::Stock.new symbol: @stock.symbol, key: ENV['AV_KEY']
    if @stock.save
      @stock.update(share_price: av_price, open_price: av_open, last_updated: DateTime.now)
      @user.balance = @user.balance - av_price.to_f*@stock.quantity
      #@user.balance = @user.balance - 60
      @user.save
      @user.transactions.create(buyorsell: "BUY", symbol: @stock.symbol, quantity: @stock.quantity, price: @stock.share_price, time: DateTime.now)
      redirect_to @stock
    else
      @stock.errors.delete(:symbol)
      @existing = Stock.find_by symbol: @stock.symbol, user_id: @user.id
      if (@existing != nil and @stock.errors.size == 0)
        puts av_price
        @existing.update(quantity: @existing.quantity + @stock.quantity, share_price: av_price, open_price: av_open, last_updated: DateTime.now)
        @existing.save
        @user.balance = @user.balance - av_price.to_f*@stock.quantity
        #@user.balance = @user.balance - 60
        @user.save
        @user.transactions.create(buyorsell: "BUY", symbol: @existing.symbol, quantity: @stock.quantity, price: @existing.share_price, time: DateTime.now)
        redirect_to @existing
      else
        render 'new'
      end
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
