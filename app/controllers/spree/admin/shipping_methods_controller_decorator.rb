Spree::Admin::ShippingMethodsController.class_eval do

  skip_before_filter :admin_required, :only => :print_test_label
  skip_before_filter :authorize_admin, :only => :print_test_label
  
  def print_test_label_test
    headers['Content-Type'] = "text/plain"
    headers['Content-Disposition'] = "attachment; filename=label_test.zpl"
    render :text => "Hello" 
  end

  def print_test_label
    require 'base64'
    # Create dummy shipment 
    shipping_method = Spree::ShippingMethod.find(params[:shipping_method_id])
    
    package = ActiveMerchant::Shipping::Package.new(10, [10,10,10], :units => Spree::ActiveShipping::Config[:units].to_sym)
    retailer = Spree::Retailer.first
    shipper = ActiveMerchant::Shipping::Location.new(
        :name           => retailer.physical_address.name, 
        :company_name   => retailer.name,
        :country        => retailer.physical_address.country.iso, 
        :state          => retailer.physical_address.state.abbr, 
        :city           => retailer.physical_address.city, 
        :zip            => retailer.physical_address.zipcode, 
        :phone          => retailer.phone, 
        :address1       => retailer.physical_address.address1, 
        :address2       => (Rails.env == 'production' ? retailer.physical_address.address2 : "Do Not Delete - Test Account")
    )
    if shipping_method.calculator.class.service_type == 'FEDEX_GROUND'
      recipient = ActiveMerchant::Shipping::Location.new(
          :name           => "Minnie Mouse", 
          :country        => "US", 
          :province       => "NY", 
          :city           => "New York", 
          :zip            => "10002", 
          :phone          => "2123456789", 
          :address1       => "45 E Houston",
          :address2       => "",
          :company        => "AMCE Evil",
          :address_type   => 'commercial' # Required for ground delivery
      )
    else
      recipient = ActiveMerchant::Shipping::Location.new(
          :name           => "Minnie Mouse", 
          :country        => "US", 
          :province       => "NY", 
          :city           => "New York", 
          :zip            => "10002", 
          :phone          => "2123456789", 
          :address1       => "45 E Houston",
          :address2       => ""
       )
    end
    
    Rails.logger.warn "Instantiating Fedex ..."
    
    fedex = ActiveMerchant::Shipping::FedEx.new(retailer.shipping_config)
    response, request_xml = fedex.ship(shipper, recipient, package, 
        :payor_account_number => retailer.shipping_config[:account], 
        :shipper_email => "r2@example.com", 
        :recipient_email => "Minnie@example.com", 
        :alcohol => true, 
        :invoice_number => '123', 
        :po_number => "TEST#{Time.now.to_i}",
        :image_type => ActiveShipping::DEFAULT_IMAGE_TYPE,
        :label_stock_type => ActiveShipping::DEFAULT_STOCK_TYPE,
        :service_type => shipping_method.calculator.class.service_type
    )
    headers['Content-Type'] = "application/zpl"
    headers['Content-Disposition'] = "attachment; filename=label_test.zpl"
    render :text => response.label 
    
  end
  
end

  
