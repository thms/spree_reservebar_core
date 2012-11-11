module Spree
  module Admin
		class BusinessGiftingsController < ResourceController
			# GET /admin/business_giftings
			# GET /admin/business_giftings.json
			def index
				@business_giftings = Spree::BusinessGifting.includes(:user).page(params[:page]).per(Spree::Config[:orders_per_page]).order("spree_business_giftings.id desc")

				respond_to do |format|
				  format.html # index.html.erb
				  format.json { render json: @business_giftings }
				end
			end

			# GET /admin/business_giftings/1
			# GET /admin/business_giftings/1.json
			def show
				@business_gifting = Spree::BusinessGifting.find(params[:id])

				respond_to do |format|
				  format.html # show.html.erb
				  format.json { render json: @business_gifting }
				end
			end

			# GET /admin/business_giftings/new
			# GET /admin/business_giftings/new.json
			def new
				@business_gifting = Spree::BusinessGifting.new

				respond_to do |format|
				  format.html # new.html.erb
				  format.json { render json: @business_gifting }
				end
			end

			# GET /admin/business_giftings/1/edit
			def edit
				@business_gifting = Spree::BusinessGifting.find(params[:id])
			end

			# POST /admin/business_giftings
			# POST /admin/business_giftings.json
			def create
				@business_gifting = Spree::BusinessGifting.new(params[:business_gifting])

				respond_to do |format|
				  if @business_gifting.save
				    format.html { redirect_to admin_business_gifting_url(@business_gifting), notice: 'Business gifting was successfully created.' }
				    format.json { render json: @business_gifting, status: :created, location: admin_business_gifting_url(@business_gifting) }
				  else
				    format.html { render action: "new" }
				    format.json { render json: @business_gifting.errors, status: :unprocessable_entity }
				  end
				end
			end

			# PUT /admin/business_giftings/1
			# PUT /admin/business_giftings/1.json
			def update
				@business_gifting = Spree::BusinessGifting.find(params[:id])

				respond_to do |format|
				  if @business_gifting.update_attributes(params[:business_gifting])
				    format.html { redirect_to admin_business_gifting_url(@business_gifting), notice: 'Business gifting was successfully updated.' }
				    format.json { head :ok }
				  else
				    format.html { render action: "edit" }
				    format.json { render json: @business_gifting.errors, status: :unprocessable_entity }
				  end
				end
			end

			# DELETE /admin/business_giftings/1
			# DELETE /admin/business_giftings/1.json
			def destroy
				@business_gifting = Spree::BusinessGifting.find(params[:id])
				@business_gifting.destroy

				respond_to do |format|
				  format.html { redirect_to admin_business_giftings_url }
				  format.json { head :ok }
				end
			end
		end
  end
end
