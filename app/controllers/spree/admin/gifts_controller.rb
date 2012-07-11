# Required to get proper access to gifts from jzebra
class Spree::Admin::GiftsController  < Spree::Admin::ResourceController

  skip_before_filter :admin_required, :only => :print_card

  skip_before_filter :authorize_admin, :only => :print_card

  # Shows the gift message, e.g. for printing via jZebra or preview
  # This needs to be pdf for jZebra to work
  def print_card
    load_gift
    authorize! :print_card, @gift, params[:token]
    respond_to do |format|
      format.html {respond_with @gift,  :template => "spree/admin/gifts/gift_card.pdf.erb", :layout => false}
      format.pdf {render :pdf => "gift_card", :template => "spree/admin/gifts/gift_card.pdf.erb", :layout => false, :orientation => 'landscape', :page_height => '152', :page_width => '102'  }
    end
  end
  
  private

  def load_gift
    @gift = Spree::Gift.find(params[:gift_id])
  end
  
end