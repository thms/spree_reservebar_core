Spree::Taxon.class_eval do


  has_attached_file :icon,
    :styles => { :mini => '32x32>', :normal => '128x128>', :product => '280x280>'},
    :default_style => :mini,
    :url => '/spree/taxons/:id/:style/:basename.:extension',
    :path => ':rails_root/public/spree/taxons/:id/:style/:basename.:extension',
    :default_url => '/assets/default_taxon.png'

  # indicate which filters should be used for a taxon
  # this method should be customized to your own site
  def applicable_filters
    fs = []
    fs << Spree::ProductFilters.taxons_below(self)
    ## unless it's a root taxon? left open for demo purposes

    fs << Spree::ProductFilters.price_filter if Spree::ProductFilters.respond_to?(:price_filter)
    fs << Spree::ProductFilters.brand_filter if Spree::ProductFilters.respond_to?(:brand_filter)
    #fs << Spree::ProductFilters.occasion_filter if Spree::ProductFilters.respond_to?(:occasion_filter)
    #fs << Spree::ProductFilters.holiday_filter if Spree::ProductFilters.respond_to?(:holiday_filter)
    fs << Spree::ProductFilters.selective_occasion_filter(self) if Spree::ProductFilters.respond_to?(:selective_occasion_filter)
    fs << Spree::ProductFilters.selective_holiday_filter(self) if Spree::ProductFilters.respond_to?(:selective_holiday_filter)
    fs
  end


end