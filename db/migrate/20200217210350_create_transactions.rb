class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.string :buyorsell
      t.string :symbol
      t.integer :quantity
      t.decimal :price
      t.datetime :time

      t.timestamps
    end
  end
end
