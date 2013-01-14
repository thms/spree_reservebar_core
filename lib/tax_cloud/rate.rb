module TaxCloud
  class Rate
    
    # takes spree addresses and looks up rate for that
    def self.lookup(retailer_address, ship_address)
      origin = TaxCloud::Address.new(
        :address1 => retailer_address.address1,
        :address2 => retailer_address.address2,
        :city => retailer_address.city,
        :state => retailer_address.state.abbr,
        :zip5 => retailer_address.zipcode     
      )
      destination = TaxCloud::Address.new(
        :address1 => ship_address.address1,
        :address2 => ship_address.address2,
        :city => ship_address.city,
        :state => ship_address.state.abbr,
        :zip5 => ship_address.zipcode     
      )
      
      transaction = TaxCloud::Transaction.new(
        :customer_id => '1',
        :cart_id => '1',
        :origin => origin,
        :destination => destination)

      transaction.cart_items << TaxCloud::CartItem.new(
        :index => 0,
        :item_id => 'SKU-100',
        :tic => TaxCloud::TaxCodes::GENERAL,
        :price => 1.00,
        :quantity => 1)
      result = Rails.cache.fetch(origin.cache_key + destination.cache_key) do
        transaction.lookup
      end
      BigDecimal.new(result.tax_amount.to_s).round(5, BigDecimal::ROUND_HALF_UP)
    end
  end
end