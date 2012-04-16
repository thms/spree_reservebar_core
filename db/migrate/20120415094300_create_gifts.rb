class CreateGifts < ActiveRecord::Migration
  def change
    create_table :spree_gifts do |t|
      t.string :first_name, :null => false, :default => ''
      t.string :last_name, :null => false, :default => ''
      t.string :email, :null => false, :default => ''
      t.string :phone, :null => false, :default => ''
      t.text :message, :null => false, :default => ''
      t.integer :sender_id, :null => false, :default => 0
      t.integer :receiver_id, :null => false, :default => 0

      t.timestamps
    end
    
    add_column :spree_orders, :gift_id, :integer
    
  end
end
