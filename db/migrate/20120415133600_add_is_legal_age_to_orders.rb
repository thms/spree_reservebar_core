class AddIsLegalAgeToOrders < ActiveRecord::Migration
  def self.up
    add_column :spree_orders, :is_legal_age, :boolean, :default => false
  end

  def self.down
    remove_column :spree_orders, :is_legal_age
  end
  
end
