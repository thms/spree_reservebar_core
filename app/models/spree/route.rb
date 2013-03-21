# Purpose: Assign products to specific retailers
# One product may be assigned to more than one retailer, since retailers may cover different geographic areas
# A route can be: preferrerd => Assign order with this SKU to this retailer
# neutral: does not impact routing decisions
# last_resort: only route order with this product to this retailer if no other retailer can fulfill the order
# 
class Spree::Route < ActiveRecord::Base
  
  set_table_name :spree_products_retailers
  
  validates_presence_of :retailer_id, :product_id
  
  belongs_to :product
  belongs_to :retailer
  
  MODES = %w{neutral preferred last_resort}
  
  scope :preferred, where(:route => 'preferred')
  scope :last_resort, where(:route => 'last_resort')
  
  
  def self.enable_all!
    Spree::Route.update_all(:is_active, true)
  end
  
  def self.disable_all!
    Spree::Route.update_all(:is_active, false)
  end
  
  def enable!
    update_attribute(:is_active, true)
  end
  
  def disable!
    update_attribute(:is_active, false)
  end
  
end
