class RetailerShippingFeesAndProductCost < ActiveRecord::Migration
  def up
    add_column :spree_retailers, :reimburse_shipping_cost, :boolean, :null => false, :default => false
    create_table :spree_product_costs do |t|
      t.integer :variant_id
      t.integer :retailer_id
      t.decimal :cost_price, :precision => 8, :scale => 2, :null => false, :default => 0.0
      t.timestamps
    end
    Spree::Retailer.all.each do |retailer|
      retailer.update_attribute(:reimburse_shipping_cost, true)
    end
    
  end

  def down
    drop_table :spree_product_costs
    remmove_column :spree_retailers, :reimburse_shipping_cost
  end
end
