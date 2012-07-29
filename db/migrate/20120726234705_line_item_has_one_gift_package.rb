class LineItemHasOneGiftPackage < ActiveRecord::Migration
  def up
    remove_column :spree_line_items, :use_gift_packaging
    add_column :spree_line_items, :gift_package_id, :integer, :null => false, :default => 0
  end


  def down
    add_column :spree_line_items, :use_gift_packaging, :boolean, :null => false, :default => false
    remove_column :spree_line_items, :gift_package_id
  end
end
