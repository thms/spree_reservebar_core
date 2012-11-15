Spree::Creditcard.class_eval do
  
  # Override to make sure w get rid of spaces before trying to ge the type, fails otherwise
  # sets self.cc_type while we still have the card number
  def set_card_type
    self.cc_type ||= CardDetector.type?(self.number.to_s.gsub(/\s/,''))
  end
  
end
