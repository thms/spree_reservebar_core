module Spree
  module ReservebarCore
    class TrackingUtils
      
      def self.tracking_service(tracking_number)
        fedex_matchers = [ /^[0-9]{15}$/ ]
        ups_matchers = [ /^.Z/, /^[HK].{10}$/ ]
        usps_matchers = [ /^E\D{1}\d{9}\D{2}$|^9\d{15,21}$/ ]
        if tracking_number =~ fedex_matchers[0]
          return 'fedex'
        elsif tracking_number =~ ups_matchers[0]
          return 'ups'
        elsif tracking_number =~ ups_matchers[1]
          return 'ups'
        elsif tracking_number =~ usps_matchers[0]
          return 'usps'
        else
          return nil
        end
      end
    end
  end
end


      