class CreateAgeGates < ActiveRecord::Migration
  def change
    create_table :spree_age_gates do |t|
      t.string :path, :null => false, :default => ""
      t.timestamps
    end
    add_index :spree_age_gates, :path
  end

end
