# Represents a brand owner such as Diageo, Moet Hennessey, etc.
class Spree::BrandOwner < ActiveRecord::Base
  
  has_many :brands

  validates_uniqueness_of :title
  
end