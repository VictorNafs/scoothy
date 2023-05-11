class CreatePurchasedProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :purchased_products do |t|
      t.integer :product_id
      t.integer :product_instance_id
      t.date :purchase_date

      t.timestamps
    end
  end
end
