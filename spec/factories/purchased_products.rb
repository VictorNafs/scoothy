FactoryBot.define do
  factory :purchased_product do
    product_id { 1 }
    product_instance_id { 1 }
    purchase_date { "2023-04-25" }
  end
end
