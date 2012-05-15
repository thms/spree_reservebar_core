# html_invoice changes options_text to something useless, so we override it back to the original here
Spree::Variant.class_eval do 
  
  has_many :product_costs
  
  def options_text
    self.option_values.sort { |ov1, ov2| ov1.option_type.position <=> ov2.option_type.position }.map { |ov| "#{ov.option_type.presentation}: #{ov.presentation}" }.to_sentence({ :words_connector => ", ", :two_words_connector => ", " })
  end
  
end
