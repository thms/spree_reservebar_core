module TaxCloud
  class Address
    def cache_key
      (address1.to_s + address2.to_s + city.to_s + state.to_s + zip.to_s).gsub(' ','')
    end
  end
end
