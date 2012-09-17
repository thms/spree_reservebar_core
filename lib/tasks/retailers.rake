namespace :admin do
  namespace :retailers do

    desc "Regular status email to retailer - indicates if any orders are not progressing as needed"
    task :regular_reminder_email => :environment do
      Spree::Retailer.active.each do |retailer|
      	Spree::RetailerMailer.regular_reminder_email(retailer).deliver
      end
    end

  end
end
