class SymbolValidator < ActiveModel::Validator
  def validate(stock)
    begin
      stk = Alphavantage::Stock.new symbol: stock.symbol, key: ENV['AV_KEY']
      puts stk
    rescue Alphavantage::Error => e
      stock.errors[:base] << "Stock symbol is invalid."
    end
  end
end

class Stock < ApplicationRecord
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates_with SymbolValidator
end
