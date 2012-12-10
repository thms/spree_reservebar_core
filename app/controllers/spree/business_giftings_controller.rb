module Spree
	class BusinessGiftingsController < BaseController

		# GET /business_giftings/new
		# GET /business_giftings/new.json
		def new
		  @business_gifting = Spree::BusinessGifting.new
		  @business_gifting.user = current_user

		  respond_to do |format|
		    format.html # new.html.erb
		    format.json { render json: @business_gifting }
		  end
		end

		# POST /business_giftings
		# POST /business_giftings.json
		def create
		  @business_gifting = Spree::BusinessGifting.new(params[:business_gifting])

		  respond_to do |format|
		    if @business_gifting.save
		      format.html { redirect_to "/business_gifting_confirmation" }
		      format.json { render json: @business_gifting, status: :created, location: @business_gifting }
		    else
		      format.html { render action: "new" }
		      format.json { render json: @business_gifting.errors, status: :unprocessable_entity }
		    end
		  end
		end

	end
end
