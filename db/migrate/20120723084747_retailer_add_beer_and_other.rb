class RetailerAddBeerAndOther < ActiveRecord::Migration
  def up
    add_column :spree_retailers, :ships_beer_to, :string, :null => false, :default => ''
    add_column :spree_retailers, :ships_other_products_to, :string, :null => false, :default => ''
    
    Spree::Retailer.all.each do |retailer|
      retailer.update_attribute(:ships_beer_to, retailer.physical_address.state.abbr)
    end
  end

  def down
    remove_column :spree_retailers, :ships_beer_to
    remove_column :spree_retailers, :ships_other_products_to
  end
end
