require 'date'

class StocksController < ApplicationController
  def index
    redirect_to manage_path
  end

  def show #shows info page for a particular stock
    #if user tries to nonexistent stock id, redirect to logged in user's portfolio
    begin
      @stock = Stock.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to manage_path
    else

      #if user tries to access another user's stock, redirect to logged in user's portfolio
      unless current_user.id == @stock.user_id
        redirect_to manage_path
        return
      end
    end
  end

  def new
    @stock = Stock.new
    current_user.stocks.each do |stock|
    @uptodate = true
      #only update stocks that haven't been updated in the last 5 minutes to prevent excessive API calls
      #(user can always manually update stock on show info page for each stock.)
      #if (stock.last_updated < DateTime.now - 5.minutes)
        begin
          #stk = Alphavantage::Stock.new symbol: params[:stock][:symbol], key: ENV['AV_KEY']
          client = IEX::Api::Client.new(
            publishable_token: ENV['AV_KEY'],
            endpoint: 'https://cloud.iexapis.com/v1'
          )
          #stock_quote = stk.quote
          stock_quote = client.quote(stock.symbol)
          #av_price = (stock_quote.price).to_f
          #av_price = (stock_quote.open).to_f
          av_price = (stock_quote.latest_price).to_f
          av_open = (stock_quote.change).to_f
          if stock_quote.latest_price == nil
            @uptodate = false
          else
            stock.update(share_price: av_price, open_price: av_open, last_updated: DateTime.now)
          end
        rescue IEX::Errors::SymbolNotFoundError => e
            @stock.errors[:base] << "API call failed. Try refreshing data again in a minute!"
            render 'new'
        end
      #end
    end
    if @uptodate == false
      @stock.errors[:base] << "One or more API calls failed, so some stock data may not be up to date. Try refreshing data in a minute!"
    render 'new'
    end
  end

  def create
    #creates a new stock or adds quantity to an existing stock when user buys a stock
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
    end
    begin
      #stk = Alphavantage::Stock.new symbol: params[:stock][:symbol], key: ENV['AV_KEY']
      client = IEX::Api::Client.new(
        publishable_token: ENV['AV_KEY'],
        endpoint: 'https://cloud.iexapis.com/v1'
      )
      #stock_quote = stk.quote
      stock_quote = client.quote(params[:stock][:symbol])
      #av_price = (stock_quote.price).to_f
      #av_price = (stock_quote.open).to_f
      av_price = (stock_quote.latest_price).to_f
      av_open = (stock_quote.change).to_f

      if av_price*(params[:stock][:quantity]).to_i > @user.balance
        #user is trying to spend more money than they have
        @stock.errors[:base] << "You do not have enough money to make this transaction."
      elsif stock_quote.latest_price == nil
        @stock.errors[:base] << "API call failed. Try again in a minute!"
      elsif @stock.save
        #transaction went through normally - update stock info and user's balance, add transaction to transaction log
        @stock.update(quantity: initQTY+(params[:stock][:quantity]).to_i, share_price: av_price, open_price: av_open, last_updated: DateTime.now)
        @user.balance = @user.balance - av_price*@stock.quantity
        @user.save
        @user.transactions.create(buyorsell: "BUY", symbol: @stock.symbol, quantity: (params[:stock][:quantity]).to_i, price: @stock.share_price, time: DateTime.now)
      end
    rescue IEX::Errors::SymbolNotFoundError => e
        @stock.errors[:base] << "API call failed. Try again in a minute!"
        render 'new'
    end
    render 'new'
  end

  def confirm
    # check for errors in buy transaction and ask user to confirm before putting it through
    @stock = Stock.new
    @user = current_user
    @qty = params[:stock][:quantity]
    @qty = @qty.to_i
    params[:stock][:symbol] = params[:stock][:symbol].upcase
    @sym = params[:stock][:symbol]
    if @qty <= 0
      @stock.errors[:base] << "Quantity must be greater than 0."
    end
    begin
      #stk = Alphavantage::Stock.new symbol: params[:stock][:symbol], key: ENV['AV_KEY']
      client = IEX::Api::Client.new(
        publishable_token: ENV['AV_KEY'],
        endpoint: 'https://cloud.iexapis.com/v1'
      )
      #stock_quote = stk.quote
      stock_quote = client.quote(params[:stock][:symbol])
      #av_price = (stock_quote.price).to_f
      #av_price = (stock_quote.open).to_f
      @av_price = (stock_quote.latest_price).to_f
      @av_open = (stock_quote.change).to_f
      if stock_quote.latest_price == nil
        @stock.errors[:base] << "API call failed. Try again in a minute!"
      end
    #rescue IEX::Errors::SymbolNotFoundError => e
    rescue IEX::Errors::SymbolNotFoundError => e
        @stock.errors[:base] << "Stock symbol is invalid."
    end
    if @stock.errors.any?
      render 'new'
    end
  end

  def sell
    #destroys or decreases quantity from a stock when user sells
    @user = current_user
    @qty = params[:stock][:quantity]
    @qty = @qty.to_i
    @stock = Stock.find_by symbol: params[:stock][:symbol], user_id: @user.id
    initQTY = @stock.quantity
    begin
      #stk = Alphavantage::Stock.new symbol: params[:stock][:symbol], key: ENV['AV_KEY']
      client = IEX::Api::Client.new(
        publishable_token: ENV['AV_KEY'],
        endpoint: 'https://cloud.iexapis.com/v1'
      )
      #stock_quote = stk.quote
      stock_quote = client.quote(params[:stock][:symbol])
      #av_price = (stock_quote.price).to_f
      #av_price = (stock_quote.open).to_f
      av_price = (stock_quote.latest_price).to_f
      av_open = (stock_quote.change).to_f

      if stock_quote.latest_price == nil
        @stock.errors[:base] << "API call failed. Try again in a minute!"
      else
        #transaction went through normally - update stock info and user's balance, add transaction to transaction log
        @stock.update(quantity: initQTY-(params[:stock][:quantity]).to_i, share_price: av_price, open_price: av_open, last_updated: DateTime.now)
        @user.balance = @user.balance + av_price*@qty
        @user.save
        @user.transactions.create(buyorsell: "SELL", symbol: @stock.symbol, quantity: (params[:stock][:quantity]).to_i, price: @stock.share_price, time: DateTime.now)

        #if user sold their last share of a stock, delete that stock and clear any errors.
        if @stock.quantity <= 0
          @stock.destroy
          @stock = Stock.new
          @stock.errors.clear
        end
      end
    rescue IEX::Errors => e
        @stock.errors[:base] << "API call failed. Try again in a minute!"
    end
    render 'new'
  end

  def sellconfirm
    # check for errors in sell transaction and ask user to confirm before putting it through
    @stock = Stock.new
    @user = current_user
    @qty = params[:stock][:quantity]
    @qty = @qty.to_i
    params[:stock][:symbol] = params[:stock][:symbol].upcase
    @sym = params[:stock][:symbol]
    if @qty <= 0
      @stock.errors[:base] << "Quantity must be greater than 0."
    end
    @existing = Stock.find_by symbol: params[:stock][:symbol], user_id: @user.id
    if @existing == nil
      @stock.errors[:base] << "You can only sell stocks you own."
    elsif @qty > @existing.quantity
      @stock.errors[:base] << "You cannot sell more of a stock than you own."
    end
    begin
      #get stock info to display to user so they can confirm their transaction
      #stk = Alphavantage::Stock.new symbol: params[:stock][:symbol], key: ENV['AV_KEY']
      client = IEX::Api::Client.new(
        publishable_token: ENV['AV_KEY'],
        endpoint: 'https://cloud.iexapis.com/v1'
      )
      #stock_quote = stk.quote
      stock_quote = client.quote(params[:stock][:symbol])
      #av_price = (stock_quote.price).to_f
      #av_price = (stock_quote.open).to_f
      @av_price = (stock_quote.latest_price).to_f
      @av_open = (stock_quote.change).to_f
      if stock_quote.latest_price == nil
        @stock.errors[:base] << "API call failed. Try again in a minute!"
      end
    rescue IEX::Errors::SymbolNotFoundError => e
        @stock.errors[:base] << "Stock symbol is invalid."
    end
    if @stock.errors.any?
      render 'new'
    end
  end

  def update
    #update information for a particular stock.
    @stock = Stock.find(params[:id])
    begin
      #stk = Alphavantage::Stock.new symbol: params[:stock][:symbol], key: ENV['AV_KEY']
      client = IEX::Api::Client.new(
        publishable_token: ENV['AV_KEY'],
        endpoint: 'https://cloud.iexapis.com/v1'
      )
      #stock_quote = stk.quote
      stock_quote = client.quote(@stock.symbol)
      #av_price = (stock_quote.price).to_f
      #av_price = (stock_quote.open).to_f
      av_price = (stock_quote.latest_price).to_f
      av_open = (stock_quote.change).to_f
      if stock_quote.latest_price == nil
        @stock.errors[:base] << "API call failed. Try refreshing data again in a minute!"
      else
        @stock.update(share_price: av_price, open_price: av_open, last_updated: DateTime.now)
      end
      render 'show'
    rescue IEX::Errors => e
        @stock.errors[:base] << "API call failed. Try refreshing data again in a minute!"
        render 'new'
    end
  end

  private
  def stock_params
    params.require(:stock).permit(:symbol, :quantity)
  end
end
