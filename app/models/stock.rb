class SymbolValidator < ActiveModel::Validator
  def validate(stock)
    puts "symbol validate begin"
    begin
      stk = Alphavantage::Stock.new symbol: stock.symbol, key: ENV['AV_KEY']
      puts stk
    rescue Alphavantage::Error => e
      stock.errors[:base] << "Stock symbol is invalid."
      #puts stock.errors[:base]
    end
    puts "symbol validate end"
  end
end

class Stock < ApplicationRecord
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  puts "quantity validated"
  validates_with SymbolValidator
end
