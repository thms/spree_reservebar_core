Spree::AppConfiguration.class_eval do
  preference :mail_bcc, :string, :default => 'management@reservebar.com'
  preference :mail_cc, :string
  preference :mail_notification_to, :string, :default => 'management@reservebar.com'
end
if Rails.env != "production"
  Spree::Config.set(:mail_bcc => "test@reservebar.com")
  Spree::Config.set(:mail_cc => "test@reservebar.com")
  Spree::Config.set(:mail_notification_to => "test@reservebar.com")
end
