# The original breaks when the user steps through the completed step on he first order.
# So we need to allow one completed order, instead of zero, but only if the current order state is not payment (or so)
# After checkout is complete and we're on the orders/show page there is only a single order in guest checkout, that order's state is complete

module Spree
  class Promotion::Rules::FirstOrder < PromotionRule
    def eligible?(order, options = {})
      user = order.try(:user) || options[:user]
      !!(user && (user.orders.complete.count == 0 || (user.orders.complete.count == 1 && user.orders.last.state == 'complete')))
    end
  end
end
