class AddTimeSlotToStockMovements < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_stock_movements, :time_slot, :integer
  end
end
