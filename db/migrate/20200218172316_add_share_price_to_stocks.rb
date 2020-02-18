class AddSharePriceToStocks < ActiveRecord::Migration[6.0]
  def change
    add_column :stocks, :share_price, :decimal
  end
end
