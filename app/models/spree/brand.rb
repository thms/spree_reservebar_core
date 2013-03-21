# Represents a brand such a s Johnnie Walker, used for limiting reporting in tags to specific brands
class Spree::Brand < ActiveRecord::Base
  
  belongs_to :brand_owner
  has_many :products
  
  validates_uniqueness_of :title
  validates_presence_of :brand_owner_id
  
  default_scope :order => "title ASC"
  
end