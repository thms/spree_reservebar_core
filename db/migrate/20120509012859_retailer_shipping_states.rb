class RetailerShippingStates < ActiveRecord::Migration
  def up
    add_column :spree_retailers, :is_super_retailer, :boolean, :null => false, :default => false
    add_column :spree_retailers, :ships_wine_to, :string, :null => false, :default => ''
    add_column :spree_retailers, :ships_spirits_to, :string, :null => false, :default => ''
    add_column :spree_retailers, :ships_champagne_to, :string, :null => false, :default => ''
    
    Spree::Retailer.all.each do |retailer|
      retailer.update_attribute(:ships_spirits_to, retailer.physical_address.state.abbr)
      retailer.update_attribute(:is_super_retailer, false)
    end
  end

  def down
    remove_column :spree_retailers, :is_super_retailer
    remove_column :spree_retailers, :ships_wine_to
    remove_column :spree_retailers, :ships_spirits_to
    remove_column :spree_retailers, :ships_champagne_to
  end
end
