class RetailersShippingMethods < ActiveRecord::Migration
  def up
    create_table :spree_retailers_shipping_methods, :id => false do |t|
      t.integer :shipping_method_id, :null => false, :default => 0  
      t.integer :retailer_id, :null => false, :default => 0
    end
    
  end

  def down
    drop_table :spree_retailers_shipping_methods
  end
end
