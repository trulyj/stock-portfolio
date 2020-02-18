class SymbolValidator < ActiveModel::Validator
  def validate(stock)
    begin
      stk = Alphavantage::Stock.new symbol: stock.symbol, key: ENV['AV_KEY']
      stk_quote = stk.quote
      p = (stk_quote.price).to_f
      puts stk
      puts stk_quote
      puts p
      #p = 60
      if p*stock.quantity > stock.user.balance
        stock.errors[:base] << "You do not have enough money to make this transaction."
      end
    rescue Alphavantage::Error => e
      stock.errors[:base] << "Stock symbol is invalid."
    end
  end
end

class Stock < ApplicationRecord
  belongs_to :user
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :symbol, presence: true, uniqueness: { scope: :user, message: "You already bought this stock." }
  #validates_with SymbolValidator
end
