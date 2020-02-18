class AddLastUpdatedToStocks < ActiveRecord::Migration[6.0]
  def change
    add_column :stocks, :last_updated, :datetime
  end
end
