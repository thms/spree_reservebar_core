class CreateCountiesRetailers < ActiveRecord::Migration
  def up
    add_column :spree_retailers, :is_default, :boolean, :null => false, :default => false
    create_table :spree_counties_retailers, :id => false do |t|
      t.integer :county_id, :null => false, :default => 0  
      t.integer :retailer_id, :null => false, :default => 0
    end
    
  end

  def down
    remove_column :spree_retailers, :is_default
    drop_table :spree_counties_retailers
  end
end
