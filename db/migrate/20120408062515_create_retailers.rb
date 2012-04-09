class CreateRetailers < ActiveRecord::Migration
  def change
    create_table :spree_retailers do |t|
      t.string :name
      t.string :dba_name
      t.string :taxid
      t.string :merchant_account
      t.references :payment_method
      t.string :gateway_login
      t.string :gateway_password
      t.string :state
      t.integer :physical_address_id
      t.integer :mailing_address_id
      t.string :phone
      t.string :fax
      t.string :mobile
      t.string :website
      t.boolean :has_pc
      t.boolean :has_internet
      t.boolean :has_wireless
      t.boolean :has_printer
      t.decimal :latitude, :precision => 11, :scale => 8
      t.decimal :longitude, :precision => 11, :scale => 8
      t.string :logo_file_name
      t.string :logo_content_type
      t.string :logo_file_size
      t.datetime :logo_updated_at
      t.string  :fedex_password, :null => false, :default => ""
      t.string  :fedex_meter, :null => false, :default => ""
      t.string  :fedex_key, :null => false, :default => ""
      t.string  :fedex_account, :null => false, :default => ""
      

      t.timestamps
    end
    add_index :spree_retailers, :payment_method_id
    add_index :spree_retailers, :physical_address_id
    add_index :spree_retailers, :mailing_address_id
  end
end
