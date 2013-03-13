# Stores the counties from the Google Fusion tables for county based decision making
class Spree::County < ActiveRecord::Base
  
  belongs_to :country
  belongs_to :state
  
  # Assign counties to retailers
  has_and_belongs_to_many :retailers, :join_table => :spree_counties_retailers
  
end