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
    @stock = Stock.find_by symbol: params[:stock][:symbol], user_id: @user.id
    initQTY = 0
    if @stock == nil
      @stock = @user.stocks.new(stock_params)
    else
      initQTY = @stock.quantity
    end
    if params[:stock][:quantity] == 0
      @stock.errors[:base] << "Quantity must be greater than 0."
      render 'new'
    end
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
      if av_price*(params[:stock][:quantity]).to_i > @user.balance
        @stock.errors[:base] << "You do not have enough money to make this transaction."
        render 'new'
      elsif @stock.save
        @stock.update(quantity: initQTY+(params[:stock][:quantity]).to_i, share_price: av_price, open_price: av_open, last_updated: DateTime.now)
        #@user.balance = @user.balance - av_price.to_f*@stock.quantity
        #@user.balance = @user.balance - 60
        #@user.save
        @user.balance = @user.balance - av_price*@stock.quantity
        @user.save
        @user.transactions.create(buyorsell: "BUY", symbol: @stock.symbol, quantity: (params[:stock][:quantity]).to_i, price: @stock.share_price, time: DateTime.now)
        redirect_to @stock
      else
        render 'new'
      end
    rescue Alphavantage::Error => e
        @stock.errors[:base] << "API call failed. Stock symbol is invalid or there may have been too many API calls. Try again in a minute!"
        render 'new'
    end
    #stock = Alphavantage::Stock.new symbol: :sym, key: ENV['AV_KEY']
    #stock_quote = stock.quote
    #puts stock_quote.symbol
    #puts stock_quote.open
  end

  def update
    @stock = Stock.find(params[:id])
    begin
      stk = Alphavantage::Stock.new symbol: @stock.symbol, key: ENV['AV_KEY']
      stock_quote = stk.quote
      av_price = (stock_quote.price).to_f
      av_open = (stock_quote.open).to_f
      @stock.update(share_price: av_price, open_price: av_open, last_updated: DateTime.now)
      redirect_to @stock
    rescue Alphavantage::Error => e
        @stock.errors[:base] << "API call failed. Stock symbol is invalid or there may have been too many API calls. Try again in a minute!"
        render 'new'
      end
    @totalval = (@stock.share_price) * (@stock.quantity)
    puts @stock.quantity
    puts @totalval
  end

  private
  def stock_params
    params.require(:stock).permit(:symbol, :quantity)
  end
end
