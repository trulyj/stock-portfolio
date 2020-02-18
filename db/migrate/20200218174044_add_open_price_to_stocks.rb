class AddOpenPriceToStocks < ActiveRecord::Migration[6.0]
  def change
    add_column :stocks, :open_price, :decimal
  end
end
