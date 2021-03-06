module Spree
  class Retailer < ActiveRecord::Base
    belongs_to :payment_method
    belongs_to :physical_address, :foreign_key => "physical_address_id", :class_name => "Spree::Address"
    belongs_to :mailing_address, :foreign_key => "mailing_address_id", :class_name => "Spree::Address"
  
    accepts_nested_attributes_for :physical_address, :reject_if => :all_blank
    accepts_nested_attributes_for :mailing_address, :reject_if => :all_blank
  
    has_and_belongs_to_many :orders, :join_table => :spree_orders_retailers
    has_and_belongs_to_many :users, :join_table => :spree_retailers_users
    has_and_belongs_to_many :tax_rates, :join_table => :spree_retailers_tax_rates
    
    # Defines the amount payable to a retailer for a given sku. Used for reporting and profit based routing.
    has_many :product_costs
    
    # Routes assign a product to a given retailer, used for retailer assignment
    has_many :routes
    
    # Find credit cards that are usable on this retailer's CIM gateway
    has_many :creditcards
    
    # Assign counties to retailers
    has_and_belongs_to_many :counties, :join_table => :spree_counties_retailers

    # Enable shipping methods for retailers
    has_and_belongs_to_many :shipping_methods, :join_table => :spree_retailers_shipping_methods
  
    validates :name, :payment_method, :phone, :email, :presence => true
  
    has_attached_file :logo,
                      :styles => { :mini => '48x48>', :thumb => '240x240>' },
                      :default_style => :thumb,
                      :url => "/system/retailers/:attachment/:id/:style/:basename.:extension",
                      :path => ":rails_root/public/system/retailers/:attachment/:id/:style/:basename.:extension"
    scope :active, where(:state => 'active')
                      
  	state_machine :initial => 'new' do
      event :activate do
        transition :from => ['new', 'suspended'], :to => 'active'
      end
      event :suspend do
        transition :from => ['new', 'active'], :to => 'suspended'
      end
    end
    
    # default retailer means this retailer can ship to any county in it's state. Only used for county-based retailer routing
    def is_default?
      self.is_default == true
    end
    
    # test if the retailer can ship an order to the county
    # assumptions: if the retailer state is not the same as the county's state, the retailer can ship (this get overruled by retailer to state assignment anyway)
    # If retailer is default in the county's state, he can ship
    # if the county is excplitely assigned to the retailer, he can ship
    # Need to pass in the state of the shipping address explicetly, because county lookup may have failed.
    def can_ship_to_county?(county, state)
      result = false
      if county == nil 
        if physical_address.state_id != state.id
          result = true
        else
          if is_default?
            result = true
          end
        end
      else # we have a county
        if (physical_address.state_id != county.state_id)
          result = true
        else
          if is_default?
            result = true
          elsif county_ids.include?(county.id)
            result = true
          end
        end
      end
      result
    end
    
    # Return nil if there is no default retailer for the state, or the default retailer for the state
    def self.default_in_state(state)
      joins(:physical_address).active.where(:is_default => true, :spree_addresses => {:state_id => state.id}).first
    end
    
    # Return all retailers in a given state
    def self.in_state(state)
      joins(:physical_address).active.where(:spree_addresses => {:state_id => state.id})
    end
    
    def not_viewed_since_submitted(number_of_hours = 3)
    	orders.where(["spree_orders.unread = ? and spree_orders.completed_at <= ? and spree_orders.state = ?", 1, Time.now - number_of_hours.hours, "complete"]).order("spree_orders.completed_at asc")
    end
    
    def not_accepted_since_viewed(number_of_hours = 12)
      orders.where(["spree_orders.viewed_at is not null and spree_orders.viewed_at <= ? and spree_orders.accepted_at is ? and spree_orders.state <> ?", Time.now - number_of_hours.hours, nil, "canceled"]).order("spree_orders.viewed_at asc")
    end
    
    def not_ready_shipping_since_accepted(number_of_hours = 6)
      orders.where(["spree_orders.accepted_at is not null and spree_orders.accepted_at <= ? and spree_orders.state <> ? and spree_orders.shipment_state = ?", Time.now - number_of_hours.hours, "canceled", "pending"]).order("spree_orders.accepted_at asc")
    end
  
    def need_notification?
      return true unless not_viewed_since_submitted.empty? && not_accepted_since_viewed.empty? && not_ready_shipping_since_accepted.empty?
    end
    
    # get the fedex/ups credentials
    # A single retailer must only have one of them set
    def shipping_config
      if Rails.env == "production"
        unless fedex_key.blank?
          {:key => fedex_key, :password => fedex_password, :account => fedex_account, :login => fedex_meter }
        else
          {:key => ups_key, :password => ups_password, :origin_account => ups_account_number, :login => ups_username }
        end
      else
        unless fedex_key.blank?
          {:key => fedex_key, :password => fedex_password, :account => fedex_account, :login => fedex_meter, :test => true }
        else
          {:key => ups_key, :password => ups_password, :origin_account => ups_account_number, :login => ups_username, :test => true }
        end
      end
    end
    
    # dummy for shipping non-shipping products
    def ships_non_shipping_to
      Spree::State.all.map(&:abbr).join(',')
    end
  end
end
