require 'date'

class StocksController < ApplicationController
  def index
    redirect_to buy_path
  end

  def show
    @stock = Stock.find(params[:id])
    unless current_user.id == @stock.user_id
      flash[:notice] = "You don't have access to that order!"
      redirect_to buy_path
      return
    end
  end

  def new
    @stock = Stock.new
    current_user.stocks.each do |stock|
    @uptodate = true
      if (stock.last_updated < DateTime.now - 5.minutes)
        begin
          stk = Alphavantage::Stock.new symbol: stock.symbol, key: ENV['AV_KEY']
          stock_quote = stk.quote
          av_price = (stock_quote.price).to_f
          av_open = (stock_quote.open).to_f
          puts stock_quote.open
          puts stock_quote.symbol
          puts stock_quote.output
          puts stock_quote.price
          if stock_quote.open == nil
            #@stock.errors[:base] << "Some stock data may not be up to date. Try refreshing data in a minute!"
            @uptodate = false
          else
            stock.update(share_price: av_price, open_price: av_open, last_updated: DateTime.now)
          end
        rescue Alphavantage::Error => e
            @stock.errors[:base] << "API call failed. Try refreshing data again in a minute!"
            render 'new'
        end
      end
    end
    if @uptodate == false
      @stock.errors[:base] << "Some stock data may not be up to date. Try refreshing data in a minute!"
    render 'new'
    end
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
        @stock.errors[:base] << "API call failed. Try again in a minute!"
        render 'new'
    end
    #stock = Alphavantage::Stock.new symbol: :sym, key: ENV['AV_KEY']
    #stock_quote = stock.quote
    #puts stock_quote.symbol
    #puts stock_quote.open
  end

  def confirm
    @stock = Stock.new
    @user = current_user
    @qty = params[:stock][:quantity]
    @qty = @qty.to_i
    @sym = params[:stock][:symbol]
    if @qty <= 0
      @stock.errors[:base] << "Quantity must be greater than 0."
      #render 'new'
    end
    begin
      stk = Alphavantage::Stock.new symbol: params[:stock][:symbol], key: ENV['AV_KEY']
      stock_quote = stk.quote
      @av_price = (stock_quote.price).to_f
      @av_open = (stock_quote.open).to_f
    rescue Alphavantage::Error => e
        #@stock = Stock.find_by symbol: params[:stock][:symbol], user_id: @user.id
        @stock.errors[:base] << "API call failed. Stock symbol is invalid or there may have been too many API calls. Try again in a minute!"
        #flash.now[:danger] = 'API call failed. Try again in a minute!'
        #render 'new'
    end
    if @stock.errors.any?
      render 'new'
    end
  end

  def sell
    puts "Enter sell"
    #@stock.errors.clear
    @user = current_user
    @qty = params[:stock][:quantity]
    @qty = @qty.to_i
    @stock = Stock.find_by symbol: params[:stock][:symbol], user_id: @user.id
    initQTY = @stock.quantity
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
      puts "OLD BALANCE"
      puts @user.balance
      @stock.update(quantity: initQTY-(params[:stock][:quantity]).to_i, share_price: av_price, open_price: av_open, last_updated: DateTime.now)
      @user.balance = @user.balance + av_price*@qty
      @user.save
      puts "NEW BALANCE"
      puts @user.balance
      @user.transactions.create(buyorsell: "SELL", symbol: @stock.symbol, quantity: (params[:stock][:quantity]).to_i, price: @stock.share_price, time: DateTime.now)
      if @stock.quantity <= 0
        @stock.destroy
        @stock = Stock.new
        @stock.errors.clear
        render 'new'
      else
        render 'new'
      end
    rescue Alphavantage::Error => e
        @stock.errors[:base] << "API call failed. Try again in a minute!"
        render 'new'
    end
    #stock = Alphavantage::Stock.new symbol: :sym, key: ENV['AV_KEY']
    #stock_quote = stock.quote
    #puts stock_quote.symbol
    #puts stock_quote.open
  end

  def sellconfirm
    @stock = Stock.new
    @user = current_user
    @qty = params[:stock][:quantity]
    @qty = @qty.to_i
    @sym = params[:stock][:symbol]
    if @qty <= 0
      @stock.errors[:base] << "Quantity must be greater than 0."
      #render 'new'
    end
    @existing = Stock.find_by symbol: params[:stock][:symbol], user_id: @user.id
    if @existing == nil
      @stock.errors[:base] << "You can only sell stocks you own."
    elsif @qty > @existing.quantity
      @stock.errors[:base] << "You cannot sell more of a stock than you own."
    end
    begin
      stk = Alphavantage::Stock.new symbol: params[:stock][:symbol], key: ENV['AV_KEY']
      stock_quote = stk.quote
      @av_price = (stock_quote.price).to_f
      @av_open = (stock_quote.open).to_f
    rescue Alphavantage::Error => e
        #@stock = Stock.find_by symbol: params[:stock][:symbol], user_id: @user.id
        @stock.errors[:base] << "API call failed. Stock symbol is invalid or there may have been too many API calls. Try again in a minute!"
        #flash.now[:danger] = 'API call failed. Try again in a minute!'
        #render 'new'
    end
    if @stock.errors.any?
      render 'new'
    end
  end

  def update
    puts "enter update"
    @stock = Stock.find(params[:id])
    begin
      stk = Alphavantage::Stock.new symbol: @stock.symbol, key: ENV['AV_KEY']
      stock_quote = stk.quote
      av_price = (stock_quote.price).to_f
      av_open = (stock_quote.open).to_f
      if stock_quote.open == nil
        @stock.errors[:base] << "API call failed. Try refreshing data again in a minute!"
        puts "NILLLLL"
      else
        @stock.update(share_price: av_price, open_price: av_open, last_updated: DateTime.now)
      end
      #@stock.update(share_price: av_price, open_price: av_open, last_updated: DateTime.now)
      render 'show'
    rescue Alphavantage::Error => e
        @stock.errors[:base] << "API call failed. Try refreshing data again in a minute!"
        render 'new'
    end
  end

  private
  def stock_params
    params.require(:stock).permit(:symbol, :quantity)
  end
end
