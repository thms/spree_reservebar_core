Spree::BaseHelper.class_eval do 

  # Override original so that the subtotal on the cart always just shows the item total and the gift packaging total, not taxes or other ite,s
  def order_subtotal(order, options={})
    options.assert_valid_keys(:format_as_currency, :show_vat_text)
    options.reverse_merge! :format_as_currency => true, :show_vat_text => true

    amount =  order.item_total + order.gift_packaging_total

    options.delete(:format_as_currency) ? number_to_currency(amount) : amount
  end
  
end
