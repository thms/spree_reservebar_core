# This controller sends ship requests to Fedex via the active shipping gem
# to get tracking labels, etc.
# ship requests are one per shipment and initiated by the retailer
# When a ship request already exists, creation of a new one requires cancellation of the existing request.
require 'base64'
class Spree::Admin::ShipmentDetailsController  < Spree::Admin::ResourceController

  include ActiveMerchant::Shipping
  skip_before_filter :authorize_admin, :only => :print_label
  
  # make a ship request to fedex and save the response here
  # update the tracking number in the associated shipment model
  def create
    shipment = Spree::Shipment.find_by_number(params[:shipment_id])
    begin
      retailer = shipment.order.retailer
      shipping_address = shipment.order.ship_address
      # get package size and weight from shipment
      multiplier = Spree::ActiveShipping::Config[:unit_multiplier]
      weight = shipment.line_items.inject(0) do |weight, line_item|
        weight + (line_item.variant.weight ? (line_item.quantity * line_item.variant.weight * multiplier) : Spree::ActiveShipping::Config[:default_weight])
      end
      # add the gift packaging weight - if any
      gift_packaging_weight = shipment.line_items.inject(0) do |weight, line_item|
        gift_packaging_weight + (line_item.gift_package ? (line_item.quantity * line_item.gift_package.weight * multiplier) : 0.0)
      end
      
      package = ActiveMerchant::Shipping::Package.new(weight + gift_packaging_weight, Spree::ActiveShipping::Config[:default_box_size], :units => Spree::ActiveShipping::Config[:units].to_sym)
      
      # make request to fedex
      shipper = ActiveMerchant::Shipping::Location.new(
          :name           => retailer.physical_address.name, 
          :company_name   => "ReserveBar", ##retailer.name,
          :country        => retailer.physical_address.country.iso, 
          :state          => retailer.physical_address.state.abbr, 
          :city           => retailer.physical_address.city, 
          :zip            => retailer.physical_address.zipcode, 
          # TODO: decide whether to use retailer.phone or retailer.physical_address.phone (the latter is currently set to "phone", which breaks FedEx)
          :phone          => retailer.phone, 
          :address1       => retailer.physical_address.address1, 
          :address2       => (Rails.env == 'production' ? retailer.physical_address.address2 : "Do Not Delete - Test Account")
      )
      recipient = ActiveMerchant::Shipping::Location.new(
          :name           => shipping_address.name, 
          :country        => shipping_address.country.iso, 
          :province       => shipping_address.state.abbr, 
          :city           => shipping_address.city, 
          :zip            => shipping_address.zipcode, 
          :phone          => shipping_address.phone, 
          :address1       => shipping_address.address1,
          :address2       => shipping_address.address2,
          :address_type   => shipping_address.is_business ? 'commercial' : 'residential'
      )
      if shipment.order.is_gift?
        # Find the email address of the giftee for this order
        recipient_email = shipment.order.gift.email
      else
        recipient_email = shipment.order.email
      end
      fedex = ActiveMerchant::Shipping::FedEx.new(retailer.shipping_config)
      response = fedex.ship(shipper, recipient, package, 
          :payor_account_number => Spree::ActiveShipping::Config[:payor_account_number], # this uses resservebar.com's account number for third party billing
          :payment_type => Spree::ActiveShipping::Config[:payment_type],
          :shipper_email => retailer.email, 
          :recipient_email => recipient_email, 
          :alcohol => true, 
          :invoice_number => shipment.number, 
          :po_number => shipment.order.number,
          :image_type => ActiveShipping::DEFAULT_IMAGE_TYPE,
          :label_stock_type => ActiveShipping::DEFAULT_STOCK_TYPE,
          :service_type => shipment.shipping_method.calculator.class.service_type
      )
    
      # store response
      if response.success?
        shipment_detail = Spree::ShipmentDetail.new(:shipment_id => shipment.id)
        shipment_detail.label = response.label
        shipment_detail.xml = response.xml
        shipment_detail.tracking_number = response.tracking_number
        shipment_detail.carrier_code = response.carrier_code
        shipment_detail.currency = response.currency
        shipment_detail.binary_barcode = response.binary_barcode
        shipment_detail.string_barcode = response.string_barcode
        shipment_detail.total_price = response.total_price
        shipment_detail.image_type = ActiveShipping::DEFAULT_IMAGE_TYPE
        shipment_detail.label_stock_type = ActiveShipping::DEFAULT_STOCK_TYPE
        shipment_detail.save
      
        # update shipment cost and tracking
        shipment.update_attributes(:tracking => response.tracking_number, :cost => response.total_price)
      end
      flash[:notice] = "Shipment is registered with FedEx"
      redirect_to admin_order_shipments_url(shipment.order)
    rescue Exception => e
      flash[:error] = e.message
      raise
      redirect_to admin_order_shipments_url(shipment.order)
    end
  end
  
  # View details of response on screen
  def show
  end
  
  # print the label to the (thermal) printer, essentially we just send the file, so it can be downloaded or printed.
  # Needs to work with tokenized permissions.
  def print_label
    load_shipment_detail
    authorize! :print_label, @shipment_detail, params[:token]
    headers['Content-Type'] = "application/zpl"
    headers['Content-Disposition'] = "attachment; filename=label_#{@shipment.number}.zpl"
    render :text => @shipment_detail.label 
  end
  

  private
  # Custom token based authorization for printing. Required, because jZebra does not send session cookies.
  def check_authorization
    load_shipment_detail
    session[:access_token] ||= params[:token]

    resource = @shipment_detail || ShipmentDetail
    action = params[:action].to_sym

    authorize! action, resource, session[:access_token]
  end
  
  def load_shipment_detail
    @shipment = Spree::Shipment.find_by_number(params[:shipment_id])
    @shipment_detail = @shipment.shipment_detail
  end
  
  
end
