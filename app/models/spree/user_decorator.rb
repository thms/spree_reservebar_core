Spree::User.class_eval do

	has_and_belongs_to_many :retailers, :join_table => :spree_retailers_users
	has_many :sent_gifts, :class_name => "Gift", :foreign_key => "sender_id"
	has_one :referral, :as => :referrible

	# Only if the user has role retailer_admin...:
	#belongs_to :retailer
	
	attr_accessor :retailer_id
	attr_accessible :retailer_id
	
	def retailer
		retailers.present? ? retailers.first : nil
	end
	
	def retailer=(obj)
		retailers.delete_all
		retailers << obj if obj.present?
	end
	
	def retailer_id
		retailer.id if retailer
	end

end
