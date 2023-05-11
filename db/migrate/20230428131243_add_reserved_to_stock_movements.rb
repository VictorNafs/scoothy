class AddReservedToStockMovements < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_stock_movements, :reserved, :boolean, default: false
  end
end
