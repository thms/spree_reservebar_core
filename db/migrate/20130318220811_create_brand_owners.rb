class CreateBrandOwners < ActiveRecord::Migration
  def change
    create_table :spree_brand_owners do |t|
      t.string :title, :null => false, :default => ''
      t.timestamps
    end
  end
end
