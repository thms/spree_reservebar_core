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
    
    has_many :product_costs
  
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
  
    # get the fedex credentials
    def shipping_config
      if Rails.env == "production"
        {:key => fedex_key, :password => fedex_password, :account => fedex_account, :login => fedex_meter }
      else
        {:key => fedex_key, :password => fedex_password, :account => fedex_account, :login => fedex_meter, :test => true }
      end
    end
    
    # dummy for shipping non-shipping products
    def ships_non_shipping_to
      Spree::State.all.map(&:abbr).join(',')
    end
  end
end
