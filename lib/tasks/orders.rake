namespace :admin do
  namespace :orders do

    desc "Sending email for  orders that have not been accepted more than 6 hours"
    task :not_accepted_notification => :environment do
      Spree::OrderMailer.not_accepted_notification(6).deliver
    end

  end
end