Spree::Taxon.class_eval do

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