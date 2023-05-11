class CreateVariantsForProducts < ActiveRecord::Migration[7.0]
  def change
    Spree::Product.find_each do |product|
      24.times do
        product.variants.create!(reserved: false)
      end
    end
  end  
end
