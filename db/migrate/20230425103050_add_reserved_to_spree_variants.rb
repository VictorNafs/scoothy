class AddReservedToSpreeVariants < ActiveRecord::Migration[7.0]
 def change
    add_column :spree_variants, :reserved, :boolean, default: false
  end
end
