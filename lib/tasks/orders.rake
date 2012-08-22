namespace :admin do
  namespace :orders do

    desc "Sending email for the orders that have not been accepted more than 6 hours"
    task :non_accepted_notify => :environment do
      Spree::OrderMailer.non_accepted_orders(6).deliver
    end

  end
end
