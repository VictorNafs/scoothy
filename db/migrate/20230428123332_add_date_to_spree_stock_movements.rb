class AddDateToSpreeStockMovements < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_stock_movements, :date, :date
  end
end
