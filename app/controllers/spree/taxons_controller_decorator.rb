Spree::TaxonsController.class_eval do
  
  private
  # Override to use the headline if available - or is that goin go to wreak havoc elsewhere? 
  def accurate_title
    @taxon ? (@taxon.headline.present? ? @taxon.headline : @taxon.name) : super
  end
end