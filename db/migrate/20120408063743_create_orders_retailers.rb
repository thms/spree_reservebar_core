class CreateOrdersRetailers < ActiveRecord::Migration
  def up
    create_table :spree_orders_retailers, :id => false do |t|
      t.integer :order_id, :null => false, :default => 0
      t.integer :retailer_id, :null => false, :default => 0
      
    end
    add_index :spree_orders_retailers, :order_id
    add_index :spree_orders_retailers, :retailer_id
  end

  def down
  	drop_table :spree_orders_retailers
  end
end
