class CreateRetailersTaxRates < ActiveRecord::Migration
  def up
    create_table :spree_retailers_tax_rates, :id => false do |t|
      t.integer :tax_rate_id, :retailer_id
    end
    add_index :spree_retailers_tax_rates, :tax_rate_id
    add_index :spree_retailers_tax_rates, :retailer_id
  end

  def down
  	drop_table :spree_retailers_tax_rates
  end
end
