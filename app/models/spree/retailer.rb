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
    
    def not_viewed_over_3_hours_since_submitted
    	orders.where(["spree_orders.unread = ? and spree_orders.completed_at <= ? and spree_orders.state = ?", 1, Time.now - 3.hours, "complete"]).order("spree_orders.completed_at asc")
    end
    
    def not_accepted_over_12_hours_since_viewed
    	orders.where(["spree_orders.viewed_at is not null and spree_orders.viewed_at <= ? and spree_orders.accepted_at is ?", Time.now - 12.hours, nil]).order("spree_orders.viewed_at asc")
    end
    
    def not_ready_shipping_over_6_hours_since_accepted
    	orders.where(["spree_orders.accepted_at is not null and spree_orders.accepted_at <= ? and spree_orders.shipment_state = ?", Time.now - 6.hours, "pending"]).order("spree_orders.accepted_at asc")
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
