class RetailerAddEmail < ActiveRecord::Migration
  def up
    add_column :spree_retailers, :email, :string, :null => false, :default => ''
  end

  def down
    remove_column :spree_retailers, :email
  end
end
