require 'date'

namespace :product_stocks do
  desc 'Populate product stocks for the next 30 days'
  task populate: :environment do
    Spree::Product.find_each do |product|
      # Assume that each product has only one variant (the master variant)
      variant = product.master

      (1..30).each do |day_offset|
        date = Date.today + day_offset
        stock_location = Spree::StockLocation.first

        # Check if there is already a stock item for this date
        existing_stock_items = variant.stock_items.joins(:stock_movements)
                                                  .where('spree_stock_movements.date = ?', date)

        next if existing_stock_items.count >= 2

        # Create stock items for this date if they do not exist yet
        (2 - existing_stock_items.count).times do
          stock_item = stock_location.stock_items.find_or_create_by(variant: variant)
          stock_movement = stock_item.stock_movements.create!(
            quantity: 2,
            date: date,
            action: 'restock'
          )
        end
      end
    end
  end
end
