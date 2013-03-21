class ProductAddBrand < ActiveRecord::Migration
  def up
    add_column :spree_products, :brand_id, :integer, :null => false, :default => 0
  end

  def down
    remove_column :spree_products, :brand_id
  end
end
