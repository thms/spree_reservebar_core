Spree::User.class_eval do


  # remove the original devise validation for uniqueness of 
  # email with lower(email), and replace it with  a version that does not use the lower() function so we can 
  # make use of fucking indices instead of table scans.
  def self.remove_email_uniq_validation
    email_uniq_validation = _validators[:email].find{ |validator| validator.is_a? ActiveRecord::Validations::UniquenessValidator }
    _validators[:email].delete(email_uniq_validation)
    filter = _validate_callbacks.find{ |c| c.raw_filter == email_uniq_validation }.filter
    skip_callback :validate, filter
  end
  remove_email_uniq_validation
  validates_uniqueness_of :email, :case_sensitive => true, :allow_blank => true, :if => :email_changed?


	has_and_belongs_to_many :retailers, :join_table => :spree_retailers_users
	has_many :sent_gifts, :class_name => "Gift", :foreign_key => "sender_id"
  has_many :complete_orders, :class_name => "Spree::Order", :conditions => "spree_orders.state = 'complete'"
  has_many :creditcards
  
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
	
	# Find all credit cards that are usable on a retailer's CIM gateway, expect the deleted ones.
	def creditcards_for_retailer(retailer)
	  creditcards.not_deleted.where(:retailer_id => retailer.id)
  end
  
  # Find the gateway_customer_profile_id for this user and retailer
  # It exists if there is at least one card that has been tokenized for this user, even if it has been deleted.
  def gateway_customer_profile_id_for_retailer(retailer)
	  creditcards.where(:retailer_id => retailer.id).where("gateway_customer_profile_id is not null").first.gateway_customer_profile_id rescue nil
  end
  
  # get all unique, tokenized, active cards for the user, i.e. get only one tokenized version of each card, instead one version for each gateway
  # so group needs to ignore different retailer_id, gateway_customer_profile_id, gateway_customer_payment_profile_id
  def unique_tokenized_cards
    creditcards.not_deleted.tokenized.group(:cc_type, :last_digits, :first_name, :last_name)
  end

end
