class CreateBrands < ActiveRecord::Migration
  def change
    create_table :spree_brands do |t|
      t.string :title, :null => false, :default => ''
      t.integer :brand_owner_id, :null => false, :default => 0
      t.timestamps
    end
  end
end
