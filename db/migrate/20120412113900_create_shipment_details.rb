class CreateShipmentDetails < ActiveRecord::Migration
  def change
    create_table :spree_shipment_details do |t|
      t.references  :shipment, :null => false
      t.string      :tracking_number, :null => false, :default => ""
      t.string      :carrier_code, :null => false, :default => ""
      t.string      :currency, :null => false, :default => ""
      t.string      :binary_barcode, :null => false, :default => ""
      t.string      :string_barcode, :null => false, :default => ""
      t.text        :xml, :null => false, :default => ""
      t.text        :label, :null => false, :default => ""
      t.decimal     :total_price, :precision => 8, :scale => 2, :null => false, :default => 0.0
      t.string      :image_type, :null => false, :default => ""
      t.string      :label_stock_type, :null => false, :default => ""
      
      t.timestamps
    end
  end
end
