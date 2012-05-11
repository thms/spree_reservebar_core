module Spree
  module ReservebarCore
    class Engine < Rails::Engine
      isolate_namespace Spree
      engine_name 'spree_reservebar_core'

      def self.activate
        Dir.glob(File.join(File.dirname(__FILE__), '../../../app/**/*_decorator*.rb')) do |c|
          Rails.configuration.cache_classes ? require(c) : load(c)
        end
      end

      config.autoload_paths += %W(#{config.root}/lib)
      config.to_prepare &method(:activate).to_proc

      initializer 'spree.reservebar_core.environment', :after => 'spree.environment' do |app|
        app.config.spree.add_class('retailers')
        app.config.spree.retailers = Spree::ReservebarCore::Environment.new
      end
      ## TODO: figure out if we need any of the below stuff
if false
      initializer 'spree.reservebar_core.register.retailer.calculators' do |app|
      end

      initializer 'spree.promo.register.promotions.rules' do |app|
        app.config.spree.promotions.rules = [
          Spree::Promotion::Rules::ItemTotal,
          Spree::Promotion::Rules::Product,
          Spree::Promotion::Rules::User,
          Spree::Promotion::Rules::FirstOrder,
          Spree::Promotion::Rules::UserLoggedIn]
      end

      initializer 'spree.promo.register.promotions.actions' do |app|
        app.config.spree.promotions.actions = [Spree::Promotion::Actions::CreateAdjustment,
          Spree::Promotion::Actions::CreateLineItems]
      end
end
    end
  end
end
