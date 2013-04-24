Spree::Address.class_eval do

	def to_string
		s = "#{address1}, "
		s << "#{address2}, " if address2.present?
		s << "#{city}, #{state_text} #{zipcode}"
		return s
	end
	
	def name
	  "#{firstname} #{lastname}"
  end

end
