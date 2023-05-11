class AddProductNumberToSpreeLineItems < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_line_items, :product_number, :integer
    add_column :spree_line_items, :date, :datetime # Ajoutez cette ligne
    add_column :spree_line_items, :time_slot, :integer # Ajoutez cette ligne
  end
end
