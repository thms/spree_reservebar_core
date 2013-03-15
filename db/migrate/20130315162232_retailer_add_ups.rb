class RetailerAddUps < ActiveRecord::Migration
  def up
    add_column :spree_retailers, :ups_key, :string, :nil => false, :default => ''
    add_column :spree_retailers, :ups_account_number, :string, :nil => false, :default => ''
    add_column :spree_retailers, :ups_username, :string, :nil => false, :default => ''
    add_column :spree_retailers, :ups_password, :string, :nil => false, :default => ''
  end

  def down
    remove_column :spree_retailers, :ups_key
    remove_column :spree_retailers, :ups_account_number
    remove_column :spree_retailers, :ups_username   
    remove_column :spree_retailers, :ups_password    
  end
end
