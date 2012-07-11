class Spree::Gift < ActiveRecord::Base
  
	belongs_to :sender, :class_name => "Spree::User"
	belongs_to :receiver, :class_name => "Spree::User"
	
	#validates :first_name, :last_name, :email, :phone, :presence => true
	
	# Use tokenized permissions to allow access from the jZebra applet
  token_resource
  
	def recipient
		"#{first_name} #{last_name}"
	end
end
