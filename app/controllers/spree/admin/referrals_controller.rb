module Spree
  module Admin
    class ReferralsController < ResourceController

			# GET /referrals
			# GET /referrals.json
			def index
				@referrals = Spree::Referral.page(params[:page]).order("spree_referrals.id desc")

				respond_to do |format|
				  format.html # index.html.erb
				  format.json { render json: @referrals }
				end
			end

			# POST /referrals
			# POST /referrals.json
			def create
				@referral = Spree::Referral.new(params[:referral])

				respond_to do |format|
				  if @referral.save
				    format.html { redirect_to admin_referral_url, notice: 'Referral was successfully created.' }
				    format.json { render json: @referral, status: :created, location: @referral }
				  else
				    format.html { render action: "new" }
				    format.json { render json: @referral.errors, status: :unprocessable_entity }
				  end
				end
			end

			# DELETE /referrals/1
			# DELETE /referrals/1.json
			def destroy
				@referral = Spree::Referral.find(params[:id])
				@referral.destroy

				respond_to do |format|
				  format.html { redirect_to admin_referrals_url }
				  format.json { head :ok }
				end
			end

    end
  end
end
