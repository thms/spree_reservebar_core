class CreateRetailersUsers < ActiveRecord::Migration
  def up
    create_table :spree_retailers_users, :id => false do |t|
      t.integer :user_id, :retailer_id
    end
    add_index :spree_retailers_users, :user_id
    add_index :spree_retailers_users, :retailer_id
  end

  def down
  	drop_table :spree_retailers_users
  end
end
