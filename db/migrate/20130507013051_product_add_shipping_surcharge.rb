class ProductAddShippingSurcharge < ActiveRecord::Migration
  def up
    add_column :spree_products, :shipping_surcharge, :decimal, :precision => 8, :scale => 6, :default => 0.0
    Spree::Product.update_all(:shipping_surcharge => 0.0)
  end

  def down
    remove_column :spree_products, :shipping_surcharge
  end
end
