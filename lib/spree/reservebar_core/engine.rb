module Spree
  module ReservebarCore
    class Engine < Rails::Engine
      isolate_namespace Spree
      engine_name 'spree_reservebar_core'

      def self.activate
        Dir.glob(File.join(File.dirname(__FILE__), '../../../app/**/*_decorator*.rb')) do |c|
          Rails.configuration.cache_classes ? require(c) : load(c)
        end
        
        # Register new searcher class
        Spree::Config.searcher_class = Spree::Search::ReservebarSearch
      end

      config.autoload_paths += %W(#{config.root}/lib)
      config.to_prepare &method(:activate).to_proc

      initializer 'spree.reservebar_core.environment', :after => 'spree.environment' do |app|
        app.config.spree.add_class('retailers')
        app.config.spree.retailers = Spree::ReservebarCore::Environment.new
      end

      initializer 'spree.promo.register.promotion.calculators', :after => 'spree.promo.environment' do |app|
        app.config.spree.calculators.promotion_actions_create_adjustments << Spree::Calculator::PercentItemTotalWithCap
        app.config.spree.calculators.promotion_actions_create_adjustments << Spree::Calculator::PercentItemTotalPlusFreeShipping
        app.config.spree.calculators.promotion_actions_create_adjustments << Spree::Calculator::FreeShippingCheapestOnly
      end

      initializer 'spree.promo.register.promotion.rules', :after => 'spree.promo.environment' do |app|
        app.config.spree.promotions.rules << Spree::Promotion::Rules::NumberOfItems
      end
     
      initializer "spree.register.calculators", :after => 'spree.core.environment' do |app|
        app.config.spree.calculators.tax_rates << Spree::Calculator::TaxWithGiftsPromosAndShipping
        app.config.spree.calculators.tax_rates << Spree::Calculator::TaxAllAdjustments
      end
      

#      initializer 'spree.promo.register.promotions.rules' do |app|
#        app.config.spree.promotions.rules << nil
#      end

    end
  end
end
